#!/bin/bash
# =============================================================================
# queue-runner.sh — External Queue Orchestrator
# =============================================================================
#
# Her feature pipeline'ini AYRI bir Claude Code process'inde calistirir.
# Boylece feature'lar arasi memory birikmez. Gece birakip sabaha calistirilabilir.
#
# Kullanim:
#   ./scripts/queue-runner.sh [all|M0|M1|M2|M3|M4|DQ] [--from ISSUE_NUMBER]
#
# Ornekler:
#   ./scripts/queue-runner.sh all                 # Tum milestone'lar (M0-M4)
#   ./scripts/queue-runner.sh M1                  # Sadece M1
#   ./scripts/queue-runner.sh DQ --from 53        # DQ issue #53'ten devam et
#   ./scripts/queue-runner.sh --from 15           # Issue #15'ten devam et
#   ./scripts/queue-runner.sh M2 --from 18        # M2, issue #18'den baslayarak
#
# Gereksinimler:
#   - gh CLI authenticated (gh auth status)
#   - claude CLI PATH'te mevcut
#   - jq yuklu
#   - develop branch'inde, guncel
#
# Mimari:
#   Bash script: kuyruk dongusu, git, gh, label, PR, merge bekleme, temizlik
#   Claude:      sadece /pipeline-run (architect -> dev -> test -> doc -> review)
#   Her feature sonrasi Claude process'i biter -> memory sifirlanir
#
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Konfigürasyon
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ISSUE_MAP="$SCRIPT_DIR/issue-map.json"
QUEUE_FILE="$SCRIPT_DIR/feature-queue.jsonl"
LOG_DIR="$PROJECT_DIR/logs/queue-run"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$LOG_DIR/run-$TIMESTAMP.log"

# Merge bekleme timeout (saniye)
MERGE_TIMEOUT=900  # 15 dakika

# Sayaclar
PROCESSED=0
SUCCEEDED=0
FAILED=0
SKIPPED=0

# Sonuc dizisi
declare -a RESULTS=()

# ---------------------------------------------------------------------------
# Loglama
# ---------------------------------------------------------------------------

mkdir -p "$LOG_DIR"

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" | tee -a "$LOG_FILE"
}

log_section() {
    log "================================================================"
    log "$1"
    log "================================================================"
}

# ---------------------------------------------------------------------------
# Arguman ayristirma
# ---------------------------------------------------------------------------

MILESTONE="all"
FROM_ISSUE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        all|M0|M1|M2|M3|M4|DQ)
            MILESTONE="$1"
            shift
            ;;
        --from)
            FROM_ISSUE="$2"
            shift 2
            ;;
        -h|--help)
            cat <<'USAGE'
queue-runner.sh — External Queue Orchestrator

Kullanim:
  ./scripts/queue-runner.sh [all|M0|M1|M2|M3|M4|DQ] [--from ISSUE_NUMBER]

Parametreler:
  all          Tum milestone'lari isle (varsayilan, M0-M4)
  M0-M4        Belirli milestone'u isle
  DQ           Design Quality refactoring issue'larini isle
  --from N     Issue #N'den devam et

Ornekler:
  ./scripts/queue-runner.sh all
  ./scripts/queue-runner.sh M1
  ./scripts/queue-runner.sh DQ --from 53
  ./scripts/queue-runner.sh --from 15
  ./scripts/queue-runner.sh M2 --from 18

Gece modu:
  nohup ./scripts/queue-runner.sh DQ --from 53 > logs/queue-run/nohup.log 2>&1 &

Loglar: logs/queue-run/
USAGE
            exit 0
            ;;
        *)
            echo "Bilinmeyen arguman: $1"
            echo "Kullanim: $0 [all|M0|M1|M2|M3|M4|DQ] [--from ISSUE_NUMBER]"
            echo "Yardim: $0 --help"
            exit 1
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Preflight kontrolleri
# ---------------------------------------------------------------------------

preflight() {
    log_section "Preflight Kontrolleri"

    # Gerekli araclar
    for cmd in gh claude jq git; do
        if ! command -v "$cmd" &>/dev/null; then
            log "HATA: $cmd bulunamadi. Lutfen yukleyin."
            exit 1
        fi
        log "  + $cmd mevcut"
    done

    # gh auth kontrol
    if ! gh auth status &>/dev/null 2>&1; then
        log "HATA: gh CLI authenticated degil. Calistirin: gh auth login"
        exit 1
    fi
    log "  + gh authenticated"

    # Repo tespiti
    local repo
    repo=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || true)
    if [[ -z "$repo" ]]; then
        log "HATA: GitHub repo tespit edilemedi"
        exit 1
    fi
    log "  + Repo: $repo"

    # Dosya kontrolleri
    for f in "$ISSUE_MAP" "$QUEUE_FILE"; do
        if [[ ! -f "$f" ]]; then
            log "HATA: Dosya bulunamadi: $f"
            exit 1
        fi
    done
    log "  + Kuyruk dosyalari mevcut"

    # develop branch'ine gec ve guncelle
    cd "$PROJECT_DIR"
    local current_branch
    current_branch=$(git branch --show-current)
    if [[ "$current_branch" != "develop" ]]; then
        log "  ! develop branch'inde degilsiniz ($current_branch). Geciliyor..."
        git checkout develop 2>/dev/null
    fi
    git pull origin develop --ff-only 2>/dev/null || true
    log "  + Branch guncel: $(git branch --show-current)"

    # Stale worktree temizligi
    git worktree prune 2>/dev/null || true
    rm -rf "$PROJECT_DIR/.claude/worktrees/" 2>/dev/null || true
    local stale_branches
    stale_branches=$(git branch | grep 'worktree-' || true)
    if [[ -n "$stale_branches" ]]; then
        echo "$stale_branches" | xargs -r git branch -D 2>/dev/null || true
        log "  + Stale worktree branch'ler temizlendi"
    fi
    log "  + Worktree durumu temiz"

    log ""
    log "Konfigürasyon:"
    log "  Milestone: $MILESTONE"
    log "  Baslangic: ${FROM_ISSUE:-"(en basta)"}"
    log "  Log dosyasi: $LOG_FILE"
    log ""
}

# ---------------------------------------------------------------------------
# Kuyruk olusturma
# ---------------------------------------------------------------------------

milestone_to_phase() {
    case "$1" in
        M0) echo 0 ;; M1) echo 1 ;; M2) echo 2 ;;
        M3) echo 3 ;; M4) echo 4 ;; *) echo "" ;;
    esac
}

# Router: milestone'a gore dogru builder'i sec
# Cikti: her satir ID|ISSUE_NUM|PIPELINE_ID|DEP1,DEP2,...|NAME
build_queue() {
    if [[ "$MILESTONE" == "DQ" ]]; then
        build_queue_github "DQ"
    else
        build_queue_jsonl
    fi
}

# M0-M4 icin: feature-queue.jsonl'den oku
build_queue_jsonl() {
    local phase_filter=""
    if [[ "$MILESTONE" != "all" ]]; then
        phase_filter=$(milestone_to_phase "$MILESTONE")
    fi

    local past_from="false"
    if [[ -z "$FROM_ISSUE" ]]; then
        past_from="true"
    fi

    while IFS= read -r line; do
        local id phase pipeline_id deps name issue_num
        id=$(echo "$line" | jq -r '.id')
        phase=$(echo "$line" | jq -r '.phase')
        pipeline_id=$(echo "$line" | jq -r '.pipeline_id')
        deps=$(echo "$line" | jq -r '.deps | join(",")')
        name=$(echo "$line" | jq -r '.name')
        issue_num=$(jq -r ".[\"$id\"] // empty" "$ISSUE_MAP")

        # Issue mapping yoksa atla
        [[ -z "$issue_num" ]] && continue

        # Milestone filtresi
        if [[ -n "$phase_filter" && "$phase" != "$phase_filter" ]]; then
            continue
        fi

        # --from: hedef issue'ya ulasana kadar atla
        if [[ "$past_from" == "false" ]]; then
            if [[ "$issue_num" == "$FROM_ISSUE" ]]; then
                past_from="true"
            else
                continue
            fi
        fi

        echo "$id|$issue_num|$pipeline_id|$deps|$name"
    done < "$QUEUE_FILE"
}

# DQ icin: issue-map.json + GitHub'dan oku
# DQ issue'lari feature-queue.jsonl'de yok, issue-map.json'da var
build_queue_github() {
    local prefix="$1"

    local past_from="false"
    if [[ -z "$FROM_ISSUE" ]]; then
        past_from="true"
    fi

    # issue-map.json'dan DQ entry'lerini sirali al (DQ-01, DQ-02, ...)
    local entries
    entries=$(jq -r "to_entries[] | select(.key | startswith(\"$prefix-\")) | [.key, (.value|tostring)] | @tsv" "$ISSUE_MAP" | sort)

    while IFS=$'\t' read -r feature_id issue_num; do
        [[ -z "$feature_id" ]] && continue

        # --from: hedef issue'ya ulasana kadar atla
        if [[ "$past_from" == "false" ]]; then
            if [[ "$issue_num" == "$FROM_ISSUE" ]]; then
                past_from="true"
            else
                continue
            fi
        fi

        # GitHub'dan issue detaylarini cek
        local issue_json
        issue_json=$(gh issue view "$issue_num" --json title,body,state 2>/dev/null || echo '{}')

        local state
        state=$(echo "$issue_json" | jq -r '.state // "UNKNOWN"')
        # Kapali issue'lari atla
        [[ "$state" == "CLOSED" ]] && continue

        local title body
        title=$(echo "$issue_json" | jq -r '.title // ""')
        body=$(echo "$issue_json" | jq -r '.body // ""')

        # Issue title'dan isim cikar: "[DQ-09] Upgrade XGPaginationDots — motion tokens"
        # → "upgrade-xgpaginationdots-motion-tokens"
        local name
        name=$(echo "$title" | sed 's/\[.*\] *//' | sed 's/ — /-/g' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')

        # Pipeline ID: feature_id'den turet: DQ-09 → dq/09
        local pipeline_id
        pipeline_id=$(echo "$feature_id" | tr '[:upper:]' '[:lower:]' | sed 's/-/\//')

        # Dependency'leri body'den cikar
        # Format: "Depends on: **DQ-01** (...), **DQ-02** (...)"
        # veya:   "Depends on #45, #46"
        local deps=""
        # Oncelik 1: **DQ-XX** formati
        local dq_deps
        dq_deps=$(echo "$body" | grep -oE '\*\*DQ-[0-9]+\*\*' | grep -oE 'DQ-[0-9]+' | paste -sd, - || true)
        if [[ -n "$dq_deps" ]]; then
            deps="$dq_deps"
        else
            # Oncelik 2: #N formati — issue numaralarindan feature ID'ye cevir
            local num_deps
            num_deps=$(echo "$body" | grep -oE 'Depends on #[0-9]+' | grep -oE '[0-9]+' || true)
            if [[ -n "$num_deps" ]]; then
                local dep_ids=()
                for dep_num in $num_deps; do
                    local dep_fid
                    dep_fid=$(jq -r "to_entries[] | select(.value == $dep_num) | .key" "$ISSUE_MAP" 2>/dev/null || true)
                    [[ -n "$dep_fid" ]] && dep_ids+=("$dep_fid")
                done
                deps=$(IFS=,; echo "${dep_ids[*]}")
            fi
        fi

        echo "$feature_id|$issue_num|$pipeline_id|$deps|$name"
    done <<< "$entries"
}

# ---------------------------------------------------------------------------
# Dependency kontrolu
# ---------------------------------------------------------------------------

deps_met() {
    local deps_str="$1"
    [[ -z "$deps_str" ]] && return 0

    IFS=',' read -ra dep_ids <<< "$deps_str"
    for dep_id in "${dep_ids[@]}"; do
        local dep_issue
        dep_issue=$(jq -r ".[\"$dep_id\"] // empty" "$ISSUE_MAP")
        [[ -z "$dep_issue" ]] && continue

        local state
        state=$(gh issue view "$dep_issue" --json state -q '.state' 2>/dev/null || echo "UNKNOWN")
        if [[ "$state" != "CLOSED" ]]; then
            return 1
        fi
    done
    return 0
}

# ---------------------------------------------------------------------------
# Feature isleme
# ---------------------------------------------------------------------------

process_feature() {
    local feature_id="$1"
    local issue_num="$2"
    local pipeline_id="$3"
    local deps="$4"
    local name="$5"

    log_section "Feature: $feature_id — $name (Issue #$issue_num)"

    # Issue zaten kapali mi?
    local issue_state
    issue_state=$(gh issue view "$issue_num" --json state -q '.state' 2>/dev/null || echo "UNKNOWN")
    if [[ "$issue_state" == "CLOSED" ]]; then
        log "  -> Zaten kapali, atlaniyor"
        ((SKIPPED++))
        return 0
    fi

    # Dependency kontrolu
    if ! deps_met "$deps"; then
        log "  -> Dependency'ler karsilanmamis, atlaniyor"
        log "    Deps: $deps"
        ((SKIPPED++))
        return 0
    fi

    local start_time
    start_time=$(date +%s)

    # --- Adim 1: Issue'yu claim et ---
    log "  [1/8] Issue claim ediliyor..."
    gh issue edit "$issue_num" \
        --add-label "status:in-progress" \
        --remove-label "status:ready" 2>/dev/null || true

    gh issue comment "$issue_num" --body "$(cat <<EOF
**Pipeline Started** (queue-runner.sh)
- Runner: queue-runner.sh (external orchestrator)
- Milestone: $MILESTONE
- Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
)" 2>/dev/null || true

    # --- Adim 2: Feature branch olustur ---
    log "  [2/8] Branch olusturuluyor: feature/$pipeline_id"
    cd "$PROJECT_DIR"
    git checkout develop 2>/dev/null
    git pull origin develop --ff-only 2>/dev/null || true

    # Branch zaten varsa gecis yap, yoksa olustur
    if git show-ref --verify --quiet "refs/heads/feature/$pipeline_id" 2>/dev/null; then
        git checkout "feature/$pipeline_id" 2>/dev/null
    else
        git checkout -b "feature/$pipeline_id" 2>/dev/null
    fi

    # --- Adim 3: Pipeline'i AYRI Claude process'inde calistir ---
    log "  [3/8] Pipeline baslatiliyor (ayri Claude process)..."
    log "         Bu uzun adim — 7 agent'lik tam pipeline"

    local pipeline_log="$LOG_DIR/pipeline-${feature_id}-${TIMESTAMP}.log"

    # Her cagri = yeni process = memory birikmez
    set +e
    claude -p "/pipeline-run $pipeline_id --issue $issue_num" \
        --dangerously-skip-permissions \
        --verbose \
        > "$pipeline_log" 2>&1
    local pipeline_exit=$?
    set -e

    if [[ $pipeline_exit -ne 0 ]]; then
        log "  X Pipeline BASARISIZ (exit code: $pipeline_exit)"
        log "    Detay: $pipeline_log"

        gh issue comment "$issue_num" --body "$(cat <<EOF
**Pipeline Failed**
- Exit code: $pipeline_exit
- Feature: $feature_id
- Log: queue-runner loglarinda

Kuyruk duraklatildi. Devam etmek icin:
\`\`\`
./scripts/queue-runner.sh $MILESTONE --from $issue_num
\`\`\`
EOF
)" 2>/dev/null || true

        gh issue edit "$issue_num" \
            --add-label "status:blocked" \
            --remove-label "status:in-progress" 2>/dev/null || true

        git checkout develop 2>/dev/null || true
        RESULTS+=("FAIL|$feature_id|#$issue_num|$name|Pipeline failed")
        return 1
    fi

    log "  + Pipeline basariyla tamamlandi"

    # --- Adim 4: Quality gate ---
    log "  [4/8] Quality gate calistiriliyor..."
    local gate_passed=true
    local gate_details=""

    # Android lint
    if [[ -f "$PROJECT_DIR/android/gradlew" ]]; then
        cd "$PROJECT_DIR/android"
        if ./gradlew ktlintCheck 2>>"$LOG_FILE" && ./gradlew detekt 2>>"$LOG_FILE"; then
            gate_details+="Android lint OK | "
        else
            gate_details+="Android lint FAIL | "
            gate_passed=false
        fi
        cd "$PROJECT_DIR"
    fi

    # iOS lint
    if command -v swiftlint &>/dev/null && [[ -d "$PROJECT_DIR/ios" ]]; then
        cd "$PROJECT_DIR/ios"
        if swiftlint lint --strict 2>>"$LOG_FILE"; then
            gate_details+="iOS lint OK"
        else
            gate_details+="iOS lint FAIL"
            gate_passed=false
        fi
        cd "$PROJECT_DIR"
    fi

    if [[ "$gate_passed" == "false" ]]; then
        log "  ! Quality gate basarisiz: $gate_details"
        log "    Otomatik duzeltme deneniyor..."

        # Otomatik fix denemesi (1 tur)
        set +e
        claude -p "Fix lint errors on branch feature/$pipeline_id. Run ktlintFormat and swiftlint --fix, then commit the fixes." \
            --dangerously-skip-permissions \
            > "$LOG_DIR/fix-${feature_id}-${TIMESTAMP}.log" 2>&1
        set -e

        # Tekrar kontrol
        gate_passed=true
        if [[ -f "$PROJECT_DIR/android/gradlew" ]]; then
            cd "$PROJECT_DIR/android"
            ./gradlew ktlintCheck 2>/dev/null && ./gradlew detekt 2>/dev/null || gate_passed=false
            cd "$PROJECT_DIR"
        fi

        if [[ "$gate_passed" == "false" ]]; then
            log "  X Quality gate otomatik fix sonrasi hala basarisiz"
            gh issue comment "$issue_num" --body "**Quality Gate Failed** — otomatik fix basarisiz.
Devam: \`./scripts/queue-runner.sh $MILESTONE --from $issue_num\`" 2>/dev/null || true
            gh issue edit "$issue_num" \
                --add-label "status:blocked" \
                --remove-label "status:in-progress" 2>/dev/null || true
            git checkout develop 2>/dev/null || true
            RESULTS+=("FAIL|$feature_id|#$issue_num|$name|Quality gate failed")
            return 1
        fi
        log "  + Otomatik fix basarili"
    fi

    log "  + Quality gate gecti: $gate_details"

    # --- Adim 5: PR olustur ---
    log "  [5/8] PR olusturuluyor..."
    git push -u origin "feature/$pipeline_id" 2>/dev/null

    local scope="${pipeline_id%%/*}"
    # DQ issue'lari refactor tipinde, digerleri feat
    local pr_type="feat"
    local pr_summary="Implements **$name** on both Android and iOS platforms."
    if [[ "$feature_id" == DQ-* ]]; then
        pr_type="refactor"
        pr_summary="Design quality upgrade: **$name**."
    fi
    local pr_url
    pr_url=$(gh pr create \
        --base develop \
        --title "$pr_type($scope): $name" \
        --body "$(cat <<EOF
## Summary
$pr_summary

Closes #$issue_num

## Changes
### Android
- Clean Architecture implementation (data/domain/presentation)
- Unit tests

### iOS
- Clean Architecture implementation (Data/Domain/Presentation)
- Unit tests

## Pipeline
Generated by \`queue-runner.sh\` (external orchestrator)
Feature: $feature_id | Pipeline: $pipeline_id

Generated by AI Agent Pipeline
EOF
)" \
        --label "agent:pipeline" 2>/dev/null || echo "")

    if [[ -z "$pr_url" ]]; then
        log "  X PR olusturulamadi"
        RESULTS+=("FAIL|$feature_id|#$issue_num|$name|PR creation failed")
        git checkout develop 2>/dev/null || true
        return 1
    fi

    log "  + PR olusturuldu: $pr_url"

    # Onayla ve auto-merge etkinlestir
    local pr_number
    pr_number=$(echo "$pr_url" | grep -oE '[0-9]+$')

    gh pr review "$pr_number" --approve \
        --body "Auto-approved by queue-runner.sh (pipeline passed)" 2>/dev/null || true
    gh pr merge "$pr_number" --auto --squash 2>/dev/null || true

    # --- Adim 6: Merge bekleme ---
    log "  [6/8] Merge bekleniyor (max $((MERGE_TIMEOUT / 60)) dk)..."
    local waited=0
    local merged=false

    while [[ $waited -lt $MERGE_TIMEOUT ]]; do
        local pr_state
        pr_state=$(gh pr view "$pr_number" --json state -q '.state' 2>/dev/null || echo "UNKNOWN")

        if [[ "$pr_state" == "MERGED" ]]; then
            merged=true
            break
        elif [[ "$pr_state" == "CLOSED" ]]; then
            log "  X PR merge olmadan kapandi"
            break
        fi

        sleep 30
        ((waited += 30))

        # Her 2 dakikada bir durum bilgisi
        if (( waited % 120 == 0 )); then
            log "    ... bekleniyor ($((waited / 60))/$((MERGE_TIMEOUT / 60)) dk)"
        fi
    done

    if [[ "$merged" == "false" ]]; then
        log "  X PR timeout icinde merge olmadi"
        RESULTS+=("FAIL|$feature_id|#$issue_num|$name|Merge timeout")
        git checkout develop 2>/dev/null || true
        return 1
    fi

    log "  + PR merge edildi"

    # --- Adim 7: Temizlik ---
    log "  [7/8] Post-merge temizlik..."
    gh issue edit "$issue_num" \
        --add-label "status:done" \
        --remove-label "status:in-progress" 2>/dev/null || true

    local duration=$(( ($(date +%s) - start_time) / 60 ))
    gh issue comment "$issue_num" --body "$(cat <<EOF
**Feature Complete** (queue-runner.sh)
- PR merged to develop
- Pipeline suresi: ${duration} dakika
EOF
)" 2>/dev/null || true

    git checkout develop 2>/dev/null
    git pull origin develop --ff-only 2>/dev/null || true

    # Branch temizligi
    git branch -d "feature/$pipeline_id" 2>/dev/null || true
    git push origin --delete "feature/$pipeline_id" 2>/dev/null || true

    # Stale worktree temizligi
    git worktree prune 2>/dev/null || true
    rm -rf "$PROJECT_DIR/.claude/worktrees/" 2>/dev/null || true
    git branch | grep 'worktree-' | xargs -r git branch -D 2>/dev/null || true

    # --- Adim 8: Bagimli issue'lari ac ---
    log "  [8/8] Bagimli issue'lar kontrol ediliyor..."
    local blocked_issues
    blocked_issues=$(gh issue list --state open --label "status:blocked" \
        --json number,body --limit 100 2>/dev/null || echo "[]")

    echo "$blocked_issues" | jq -c '.[]' 2>/dev/null | while IFS= read -r blocked; do
        local b_num b_body
        b_num=$(echo "$blocked" | jq -r '.number')
        b_body=$(echo "$blocked" | jq -r '.body')

        # Body'den dependency issue numaralarini cek
        # Format 1: "Depends on #45" (M0-M4)
        # Format 2: "**DQ-01**" (DQ)
        local dep_nums=""

        # #N formatindaki dep'ler
        local hash_deps
        hash_deps=$(echo "$b_body" | grep -oE 'Depends on #[0-9]+' | grep -oE '[0-9]+' || true)
        dep_nums="$hash_deps"

        # **XX-NN** formatindaki dep'ler → issue numarasina cevir
        local ref_deps
        ref_deps=$(echo "$b_body" | grep -oE '\*\*[A-Z]+-[0-9]+\*\*' | grep -oE '[A-Z]+-[0-9]+' || true)
        for ref in $ref_deps; do
            local ref_num
            ref_num=$(jq -r ".[\"$ref\"] // empty" "$ISSUE_MAP" 2>/dev/null || true)
            [[ -n "$ref_num" ]] && dep_nums="$dep_nums $ref_num"
        done

        dep_nums=$(echo "$dep_nums" | tr -s ' ' | sed 's/^ //')
        [[ -z "$dep_nums" ]] && continue

        # Tum dependency'ler kapandi mi?
        local all_closed=true
        for d in $dep_nums; do
            local d_state
            d_state=$(gh issue view "$d" --json state -q '.state' 2>/dev/null || echo "OPEN")
            if [[ "$d_state" != "CLOSED" ]]; then
                all_closed=false
                break
            fi
        done

        if [[ "$all_closed" == "true" ]]; then
            log "    Aciliyor: issue #$b_num"
            gh issue edit "$b_num" --add-label "status:ready" --remove-label "status:blocked" 2>/dev/null || true
            gh issue comment "$b_num" --body "**Unblocked** — Tum dependency'ler tamamlandi. Pipeline icin hazir." 2>/dev/null || true
        fi
    done

    log "  + Feature $feature_id tamamlandi (${duration} dk)"
    RESULTS+=("OK|$feature_id|#$issue_num|$name|${duration}dk")
    ((SUCCEEDED++))
    return 0
}

# ---------------------------------------------------------------------------
# Ozet
# ---------------------------------------------------------------------------

print_summary() {
    log ""
    log_section "Kuyruk Ozeti"
    log "Islenen:   $PROCESSED feature"
    log "Basarili:  $SUCCEEDED feature"
    log "Basarisiz: $FAILED feature"
    log "Atlanan:   $SKIPPED feature (kapali veya dep karsilanmamis)"
    log ""

    if [[ ${#RESULTS[@]} -gt 0 ]]; then
        log "Sonuclar:"
        for r in "${RESULTS[@]}"; do
            IFS='|' read -r status fid inum fname detail <<< "$r"
            if [[ "$status" == "OK" ]]; then
                log "  OK  $inum - $fid ($fname) — $detail"
            else
                log "  FAIL $inum - $fid ($fname) — $detail"
            fi
        done
    fi

    log ""
    log "Log dosyasi: $LOG_FILE"
    log "Pipeline loglari: $LOG_DIR/pipeline-*-$TIMESTAMP.log"

    # Fail varsa devam komutu goster
    if [[ $FAILED -gt 0 ]]; then
        for r in "${RESULTS[@]}"; do
            IFS='|' read -r status fid inum fname detail <<< "$r"
            if [[ "$status" == "FAIL" ]]; then
                local num="${inum#\#}"
                log ""
                log "Devam etmek icin: ./scripts/queue-runner.sh $MILESTONE --from $num"
                break
            fi
        done
    fi
}

# ---------------------------------------------------------------------------
# Ana dongu
# ---------------------------------------------------------------------------

main() {
    log_section "XiriGo Queue Runner — $(date)"

    preflight

    log "Kuyruk hazirlaniyor..."
    local queue=()
    while IFS= read -r entry; do
        [[ -n "$entry" ]] && queue+=("$entry")
    done < <(build_queue)

    local total=${#queue[@]}
    log "Kuyruk: $total feature islenecek"
    log ""

    if [[ $total -eq 0 ]]; then
        log "Islenecek feature yok. Tamamlandi."
        return 0
    fi

    # Feature listesi
    for entry in "${queue[@]}"; do
        IFS='|' read -r fid inum pid deps fname <<< "$entry"
        log "  -> $fid (#$inum) $fname"
    done
    log ""

    # Her feature'i isle
    for entry in "${queue[@]}"; do
        IFS='|' read -r fid inum pid deps fname <<< "$entry"

        set +e
        process_feature "$fid" "$inum" "$pid" "$deps" "$fname"
        local result=$?
        set -e

        ((PROCESSED++))

        if [[ $result -ne 0 ]]; then
            ((FAILED++))
            log ""
            log "DURDURULDU — Feature basarisiz oldu (Kural 7: hata durumunda dur)"
            break
        fi

        log ""
    done

    print_summary
}

main "$@"
