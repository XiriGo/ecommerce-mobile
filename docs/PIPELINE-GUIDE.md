# XiriGo Mobile — Agentic Pipeline Guide

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/create-feature M1-09 "Title"` | Yeni feature issue olustur |
| `/pipeline-run m1/product-list --issue 12` | Tek feature icin agent team calistir |
| `/queue-run all` | Tum feature'lari sirayla kodla |
| `/queue-run M1` | Tek milestone calistir |
| `/queue-run --from 15` | Belirli issue'dan devam et |
| `./scripts/queue-runner.sh M1` | Gece modu — her feature ayri process (memory leak yok) |
| `/verify all` | Build + lint + test kontrol |
| `/create-pr develop --closes 12 --auto-merge` | PR olustur + auto-merge |
| `make all` | Build + lint + test (her iki platform) |
| `make android` / `make ios` | Tek platform build + lint + test |
| `make lint` | Lint + suppress check |
| `make check-suppress` | Zero suppression kontrolu |

---

## 1. Yeni Feature Olusturma (`/create-feature`)

Yeni bir feature eklemek istediginde bu komutu kullan. GitHub Issue'yu full template ile olusturur, label/milestone/project board atar, dependency'leri kontrol eder.

### Kullanim

```bash
# Basit feature
/create-feature M1-09 "Product Comparison"

# Dependency'li, yuksek oncelikli
/create-feature M2-08 "Order Tracking" --deps M2-05,M3-01 --priority p1

# Altyapi isi
/create-feature M0-07 "Push Notification Setup" --type infra --priority p0

# Tek platform
/create-feature M1-10 "Widget" --platform android

# Aciklama ile
/create-feature M4-06 "Dark Mode" --description "Toggle dark/light theme from settings"
```

### Parametreler

| Parametre | Zorunlu | Default | Ornekler |
|-----------|---------|---------|----------|
| Feature ID | Evet | — | `M1-09`, `M2-08` |
| Title | Evet | — | `"Product Comparison"` |
| `--deps` | Hayir | yok | `--deps M1-06,M1-07` veya `--deps #12,#13` |
| `--priority` | Hayir | `p2` | `--priority p0` |
| `--platform` | Hayir | `both` | `--platform android` |
| `--type` | Hayir | `feature` | `--type infra`, `--type fix` |
| `--description` | Hayir | otomatik | `--description "Kisa aciklama"` |

### Ne Yapar

1. `PROMPTS/BUYER_APP.md` ve `shared/api-contracts/`'den gereksinimleri toplar
2. Full template ile GitHub Issue olusturur (requirements, API endpoints, acceptance criteria, pipeline checklist)
3. Label'lari atar: `type:feature` + `platform:both` + `phase:m1` + `priority:p2` + `status:ready`
4. Milestone'a atar (M0-M4)
5. GitHub Project "XiriGo Mobile Roadmap" board'a ekler
6. Dependency'leri kontrol eder — hepsi closed ise `status:ready`, degilse `status:blocked`
7. `scripts/issue-map.json`'i gunceller ve commit eder

---

## 2. Tek Feature Pipeline (`/pipeline-run`)

Bir feature'i bastan sona kodlamak icin agent team olusturur. 7 uzman agent paralel calisir.

### Kullanim

```bash
# Feature ID ile
/pipeline-run m0/design-system --issue 3

# Pipeline ID ile
/pipeline-run m1/product-list --issue 12
```

### Agent Team Yapisi

```
Architect → [Android Dev ‖ iOS Dev] → [Android Tester ‖ iOS Tester] → Doc Writer → Reviewer → Quality Gate
```

| Agent | Model | Gorevi |
|-------|-------|--------|
| Architect | Opus | Platform-agnostic spec tasarla |
| Android Dev | Opus | Kotlin + Jetpack Compose implementasyonu |
| iOS Dev | Opus | Swift + SwiftUI implementasyonu |
| Android Tester | Sonnet | JUnit + MockK + Turbine testleri |
| iOS Tester | Sonnet | Swift Testing + ViewInspector testleri |
| Doc Writer | Sonnet | Feature docs + CHANGELOG |
| Reviewer | Opus | Cross-platform review (FAANG standartlari) |

### Pipeline Adimlari

| # | Adim | Agent | Cikti |
|---|------|-------|-------|
| 1 | Feature spec tasarla | Architect | `shared/feature-specs/{name}.md` |
| 2 | Android implement et | Android Dev | `android/app/.../feature/{name}/` |
| 3 | iOS implement et | iOS Dev | `ios/XiriGoEcommerce/Feature/{Name}/` |
| 4 | Android test yaz | Android Tester | `android/app/src/test/.../` |
| 5 | iOS test yaz | iOS Tester | `ios/XiriGoEcommerceTests/` |
| 6 | Dokumantasyon yaz | Doc Writer | `docs/features/{name}.md` + CHANGELOG |
| 7 | Cross-platform review | Reviewer | `docs/pipeline/{name}-review.handoff.md` |
| 8 | Quality gate | Team Lead | ktlint + detekt + SwiftLint + test |

Adim 2-3 paralel calisir. Adim 4-5 paralel calisir.

### Commit Convention

Her agent kendi commit'ini atar:

```
feat(product): implement product list [agent:android-dev] [platform:android]
feat(product): implement product list [agent:ios-dev] [platform:ios]
test(product): add product list tests [agent:android-test] [platform:android]
docs(product): add documentation [agent:doc] [platform:both]
chore(product): review approved [agent:review]
```

### Pipeline Sonunda

- PR olusturulur: `feat(product): implement product list`
- PR body'de: `Closes #12` (issue otomatik kapanir)
- Label: `agent:pipeline`
- Auto-merge: squash merge etkinlestirilir

---

## 3. Queue Runner (`/queue-run`)

Birden fazla feature'i sirayla otomatik kodlar. GitHub Issues API'den `status:ready` olan issue'lari alir, dependency sirasina gore isler.

### Kullanim

```bash
# Tum feature'lari sirayla kodla (34 feature)
/queue-run all

# Tek milestone
/queue-run M0
/queue-run M1
/queue-run M2

# Belirli issue'dan devam et (daha once durmus ise)
/queue-run --from 15
```

### Calisma Mantigi

```
1. GitHub'dan status:ready issue'lari cek
2. Dependency sirasina gore sirala (topological sort)
3. Her issue icin:
   a. Issue'yu claim et (status:in-progress)
   b. Branch olustur: feature/{pipeline_id}
   c. Pipeline'i IZOLE SUBAGENT icerisinde calistir
   d. Quality gate: build + lint + test
   e. PR olustur (Closes #N) + auto-merge
   f. Issue'yu kapat (status:done)
   g. Bagimli issue'lari kontrol et → status:ready yap
   h. develop'a don, sonraki issue'ya gec
4. Ozet tablosu yazdir
```

### Memory Izolasyonu

`/queue-run` her pipeline-run'i **izole bir Agent subagent** icerisinde calistirir:

- Her feature'in tum context'i (dosya okumalari, build ciktilari, git islemleri, agent team) **izole** kalir
- Subagent bittiginde context **garbage-collected** olur
- Ana queue-run conversation'ina sadece kisa ozet doner
- 10+ feature calistirsan bile ana context **minimal** kalir
- Gece birak, sabaha kadar sorunsuz calissin

Alternatif olarak daha guclu izolasyon icin `scripts/queue-runner.sh` kullanilabilir (her feature tamamen ayri OS process'inde calisir).

### Hata Durumu

- Pipeline fail olursa → issue'ya comment eklenir, `status:blocked` yapilir
- Queue durur, kullaniciya raporlanir
- Devam etmek icin: `/queue-run --from {issue_number}`
- Max 2 fix denemesi yapilir, sonra durulur

### Ornek Cikti

```
====================================
Queue Run Summary
====================================
Processed: 6 features
Succeeded: 5 features
Failed:    1 feature
Remaining: 28 features (open)

Completed:
  ✅ #3 - [M0-02] Design System
  ✅ #4 - [M0-03] Network Layer
  ✅ #5 - [M0-04] Navigation
  ✅ #6 - [M0-05] DI Setup
  ✅ #7 - [M0-06] Auth Infrastructure

Failed:
  ❌ #8 - [M1-01] Login - SwiftLint error

Next: /queue-run --from 8
====================================
```

---

## 4. M0 Pipeline Sirasi

M0 spec'leri hazir. Pipeline siralari:

```
M0-02 Design System  ──┐
M0-03 Network Layer  ──┼── Paralel calistirilabilir
M0-04 Navigation     ──┤
M0-05 DI Setup       ──┘
                        │
                        ▼
M0-06 Auth Infrastructure ── M0-03 + M0-05'e bagimli
```

### Manuel Baslat (Tek Tek)

```bash
# Paralel baslatilabilir (birbirinden bagimsiz)
/pipeline-run m0/design-system --issue 3
/pipeline-run m0/network-layer --issue 4
/pipeline-run m0/navigation --issue 5
/pipeline-run m0/di-setup --issue 6

# M0-03 ve M0-05 tamamlandiktan sonra
/pipeline-run m0/auth-infrastructure --issue 7
```

### Otomatik (Queue Runner)

```bash
# M0'i otomatik isle (dependency sirasini kendisi cozer)
/queue-run M0
```

### Gece Modu (External Orchestrator)

Uzun sureli unattended calisma icin `queue-runner.sh` kullan.
Her feature ayri Claude Code process'inde calisir — memory birikmez.

```bash
# Tum feature'lari gece birak
nohup ./scripts/queue-runner.sh all > logs/queue-run/nohup.log 2>&1 &

# Tek milestone
nohup ./scripts/queue-runner.sh M1 > logs/queue-run/nohup.log 2>&1 &

# Kaldigi yerden devam
./scripts/queue-runner.sh --from 15
```

Detayli kullanim kilavuzu: `docs/queue-runner.md`

---

## 5. Quality Gate (`/verify`)

Build, lint ve test kontrollerini calistirir.

```bash
# Her iki platform
/verify all

# Tek platform
/verify android
/verify ios
```

### Kontroller

| Platform | Kontrol | Komut |
|----------|---------|-------|
| Android | ktlint | `./gradlew ktlintCheck` |
| Android | detekt | `./gradlew detekt` |
| Android | build | `./gradlew assembleDebug` |
| Android | test | `./gradlew test` |
| Android | suppress check | `grep -rn '@Suppress' --include='*.kt' android/app/src/main/` (must be empty) |
| iOS | SwiftLint | `swiftlint lint --strict` |
| iOS | SwiftFormat | `swiftformat --lint .` |
| iOS | build | `xcodebuild build` |
| iOS | test | `xcodebuild test` |
| iOS | suppress check | `grep -rn 'swiftlint:disable' --include='*.swift' ios/` (must be empty) |

### Suppression Gate (Zero Tolerance)

Pipeline agent'lari `@Suppress` (Android) veya `swiftlint:disable` (iOS) kullanarak lint kurallarini bypass edemez. Kural tetiklenirse, agent kodu duzelir veya lint aracini dogru sekilde konfigure eder. Detaylar: `docs/standards/faang-rules.md`

---

## 6. PR Olusturma (`/create-pr`)

Mevcut branch'i push eder ve PR olusturur.

```bash
# Basit PR
/create-pr develop

# Issue baglayarak
/create-pr develop --closes 12

# Auto-merge ile
/create-pr develop --closes 12 --auto-merge
```

### PR Icerigi

- Title: `feat({scope}): {description}`
- Body: Pipeline status tablosu + platform degisiklikleri
- Label: `agent:pipeline`
- `Closes #{N}` ile issue otomatik kapanir

---

## 7. Review (`/review-agent`)

FAANG standardlarinda cross-platform review yapar.

```bash
/review-agent product-list
```

### 12 Review Kategorisi

1. **Spec Compliance** — Tum ekranlar/state'ler implement edilmis mi
2. **Code Quality** — No `Any`, no `!!`, no force unwrap, explicit types
3. **Architecture** — Clean Architecture katmanlari, dependency direction
4. **Design System** — `XG*` component kullanimi, magic number yok
5. **Performance** — N+1 yok, gereksiz recomposition yok, key parametresi
6. **Memory & Thread Safety** — Leak yok, `[weak self]`, structured concurrency
7. **Error Handling** — Try/catch + domain error mapping, no silent swallow
8. **Security** — Log'da hassas veri yok, auth token guvenli
9. **Accessibility** — contentDescription/accessibilityLabel, min touch target
10. **Test Coverage** — >= 80% line, >= 70% branch
11. **Cross-Platform Consistency** — Ayni davranis, ayni model, ayni flow
12. **Localization** — Tum string'ler resource dosyasinda, 3 dil

### Severity

- **CRITICAL**: Merge oncesi duzeltilmeli (architecture violation, security, crash)
- **WARNING**: Duzeltilmeli (code quality, performance, eksik test)
- **INFO**: Iyi olur (stil onerisi, dokumantasyon iyilestirme)

---

## 8. GitHub Yapisi

### Labels

| Grup | Label'lar |
|------|-----------|
| Type | `type:feature`, `type:infra`, `type:fix` |
| Platform | `platform:android`, `platform:ios`, `platform:both` |
| Phase | `phase:m0` ... `phase:m4` |
| Priority | `priority:p0` (critical), `priority:p1` (high), `priority:p2` (normal) |
| Status | `status:ready`, `status:blocked`, `status:in-progress`, `status:done` |
| Agent | `agent:pipeline` |

### Milestones

| Milestone | Kapsam | Feature Sayisi |
|-----------|--------|---------------|
| M0: Foundation | Scaffold, design system, network, nav, DI, auth | 6 |
| M1: Core Features | Login, register, home, categories, products, search | 8 |
| M2: Commerce | Cart, wishlist, address, checkout, payment | 7 |
| M3: User Features | Orders, profile, payments, notifications, settings, reviews, vendors | 8 |
| M4: Enhancements | Q&A, recently viewed, price alerts, share, onboarding | 5 |

### Project Board (Kanban)

```
Backlog → Ready → In Progress → In Review → Done
```

### Traceability Chain

```
GitHub Issue #12 "[M1-06] Product List"
  ├── Labels: type:feature, platform:both, phase:m1, priority:p2
  ├── Milestone: M1: Core Features
  ├── Dependencies: Depends on #3, #4, #5
  │
  ├── Branch: feature/m1/product-list
  │   ├── docs(specs): add product-list spec [agent:architect]
  │   ├── feat(product): implement product list [agent:android-dev] [platform:android]
  │   ├── feat(product): implement product list [agent:ios-dev] [platform:ios]
  │   ├── test(product): add tests [agent:android-test] [platform:android]
  │   ├── test(product): add tests [agent:ios-test] [platform:ios]
  │   ├── docs(product): add documentation [agent:doc]
  │   └── chore(product): review approved [agent:review]
  │
  ├── PR #45 "feat(product): implement product list"
  │   ├── Body: "Closes #12"
  │   ├── Label: agent:pipeline
  │   ├── CI: Android ✅ (lint + build + test) | iOS ✅ (lint + build + test)
  │   └── Auto-merged (squash) → develop
  │
  ├── Issue #12: Closed (status:done)
  └── Dependent issues (#13, #14) → status:ready
```

---

## 9. CI/CD Workflows

| Workflow | Trigger | Ne Yapar |
|----------|---------|----------|
| `android-ci.yml` | Push to `feature/**`, PR to `develop` | ktlint + detekt + build + test |
| `ios-ci.yml` | Push to `feature/**`, PR to `develop` | SwiftLint + SwiftFormat + build + test |
| `pr-gate.yml` | PR to `develop`/`main` | Combined gate (path filtering ile) |
| `auto-merge.yml` | Review approved + checks passed | `agent:pipeline` label'li PR'lari squash merge |

### Branch Protection (Manuel Ayar)

GitHub Settings > Branches > Branch protection rules > `develop`:
- Required status check: `pr-gate-result`
- Require review before merging

---

## 10. FAANG Kod Standartlari

### Complexity Limitleri

| Metrik | Limit |
|--------|-------|
| Cyclomatic complexity | <= 10 |
| Function body | <= 60 satir |
| File length | <= 400 satir |
| Method parameters | <= 6 |
| Line length | <= 120 karakter |

### Zorunlu Kurallar

- **Android**: No `Any`, no `!!`, no `var` state, explicit return types, `@Stable`, `@HiltViewModel`
- **iOS**: No force unwrap (`!`), no `Any`, `@MainActor` + `@Observable` on ViewModels, `final class`
- **Her ikisi**: Immutable models, domain errors as sealed/enum, no hardcoded strings, `XG*` components

### Architecture Tests

| Test | Ne Kontrol Eder |
|------|-----------------|
| Domain layer isolation | Domain'de data/presentation import'u yok |
| Presentation layer isolation | Presentation'da data import'u yok |
| Design system usage | Feature screen'lerde raw Material3/SwiftUI yok |
| ViewModel rules | Context import yok (Android), @MainActor var (iOS) |
| Preview requirement | Her screen composable'da @Preview var |

---

## 11. Dosya Yapisi

### Issue Map
```
scripts/issue-map.json    # Feature ID → GitHub issue number mapping
```

### Agent Tanimlari
```
.claude/agents/           # Agent definitions (model, tools, memory)
.claude/skills/           # Skill prompts (detailed instructions)
```

### Lint Configs
```
android/config/detekt/detekt.yml    # Detekt rules
android/.editorconfig               # ktlint rules
ios/.swiftlint.yml                  # SwiftLint rules
ios/.swiftformat                    # SwiftFormat rules
.editorconfig                       # Root editor config
```

### CI/CD
```
.github/workflows/android-ci.yml   # Android CI
.github/workflows/ios-ci.yml       # iOS CI
.github/workflows/pr-gate.yml      # PR quality gate
.github/workflows/auto-merge.yml   # Auto-merge
```

### Pre-commit Hooks
```
scripts/setup-hooks.sh              # Hook installer: ./scripts/setup-hooks.sh
scripts/pre-commit                  # Hook script (ktlint + SwiftLint)
```

---

## 12. Hizli Baslangilc

### Ilk Kurulum (Bir Kere)

```bash
# Pre-commit hook'larini kur
./scripts/setup-hooks.sh

# GitHub CLI auth kontrol
gh auth status
```

### Gunluk Kullanim

```bash
# Yeni feature ekle
/create-feature M1-09 "Product Comparison" --deps M1-06

# Tek feature kodla
/pipeline-run m1/product-comparison --issue 36

# Veya tum milestone'u kodla
/queue-run M1

# Quality check
/verify all

# PR olustur
/create-pr develop --closes 36 --auto-merge
```

### Gece Birakma

```bash
# Milestone'u gece birak
nohup ./scripts/queue-runner.sh M1 > logs/queue-run/nohup.log 2>&1 &

# Sabah kontrol
tail -50 logs/queue-run/run-*.log
```

### Hata Durumunda

```bash
# Queue durdu mu? Kaldigi yerden devam et
/queue-run --from 15

# Lint hatalari? Kontrol et
/verify android
/verify ios

# Review istegi?
/review-agent product-comparison
```
