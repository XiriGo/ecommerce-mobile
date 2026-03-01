# Queue Runner — External Orchestrator

## Problem

`/queue-run` komutu tek bir Claude Code session'inda calisir. Her feature 7 agent uretir (architect, android-dev, ios-dev, android-tester, ios-tester, doc-writer, reviewer). 34 feature x 7 agent = ~238 agent cagirisi tek process'te birikir ve memory siser.

Kisa isler icin sorun yok (3-5 feature). Ama gece birakip 10+ feature isletirken terminal yavaslar veya craslenir.

## Cozum

`scripts/queue-runner.sh` — **her feature'i ayri bir Claude Code process'inde calistirir**.

```
Bash script (hafif, memory birikmez)
  |
  +-- Feature 1: claude -p "/pipeline-run ..." --> process biter, memory sifirlanir
  +-- Feature 2: claude -p "/pipeline-run ..." --> process biter, memory sifirlanir
  +-- Feature 3: claude -p "/pipeline-run ..." --> process biter, memory sifirlanir
  +-- ...
```

Her feature sonrasi Claude process'i tamamen kapanir. Yeni feature = yeni process = sifir memory.

## Gereksinimler

| Arac | Kontrol komutu |
|------|---------------|
| `gh` | `gh auth status` |
| `claude` | `claude --version` |
| `jq` | `jq --version` |
| `git` | `git --version` |

## Kullanim

### Temel komutlar

```bash
# Tum milestone'lari isle
./scripts/queue-runner.sh all

# Tek milestone
./scripts/queue-runner.sh M0
./scripts/queue-runner.sh M1
./scripts/queue-runner.sh M2

# Belirli issue'dan devam et
./scripts/queue-runner.sh --from 15

# Milestone + from birlikte
./scripts/queue-runner.sh M2 --from 18
```

### Gece modu (unattended)

Terminal'i kapattiginda da devam etsin:

```bash
# nohup ile arka planda calistir
nohup ./scripts/queue-runner.sh M1 > logs/queue-run/nohup.log 2>&1 &

# PID'yi not al (durdurmak icin)
echo $!
# Ornek: 12345

# Sabah kontrol
tail -f logs/queue-run/nohup.log

# Durdurmak istersen
kill 12345
```

tmux veya screen kullaniyorsan:

```bash
# tmux ile
tmux new-session -d -s queue './scripts/queue-runner.sh M1'

# Sabah baglan
tmux attach -t queue

# screen ile
screen -dmS queue ./scripts/queue-runner.sh M1

# Sabah baglan
screen -r queue
```

### Yardim

```bash
./scripts/queue-runner.sh --help
```

## Adimlar (her feature icin)

Script her feature icin su adimlari izler:

| # | Adim | Kim yapar |
|---|------|-----------|
| 1 | Issue claim et (`status:in-progress`) | Bash (gh) |
| 2 | Feature branch olustur | Bash (git) |
| 3 | Pipeline calistir (7 agent) | Claude (ayri process) |
| 4 | Quality gate (lint + test) | Bash (gradle/swiftlint) |
| 5 | PR olustur + auto-merge | Bash (gh) |
| 6 | Merge bekleme (max 15 dk) | Bash (poll) |
| 7 | Post-merge temizlik | Bash (git + gh) |
| 8 | Bagimli issue'lari ac | Bash (gh) |

Adim 3 haric her sey bash'te. Adim 3'te yeni bir Claude Code process'i baslatilir ve tamamlandiktan sonra o process kapanir.

## Log dosyalari

Her calistirmada otomatik log olusur:

```
logs/queue-run/
  run-20260301-220000.log              # Ana log (tum adimlar)
  pipeline-M0-02-20260301-220000.log   # Feature-bazli Claude ciktisi
  pipeline-M0-03-20260301-220000.log
  fix-M0-02-20260301-220000.log        # Lint fix denemesi (varsa)
```

Sabah ne oldugunu gormek icin:

```bash
# Ana log'un sonunu goster
tail -50 logs/queue-run/run-*.log

# En son log dosyasi
ls -t logs/queue-run/run-*.log | head -1 | xargs tail -50

# Basarisiz pipeline'in detayi
cat logs/queue-run/pipeline-M1-01-*.log
```

## Hata durumu

### Feature basarisiz olursa

Script durur (Kural 7). Log'un sonunda devam komutu yazar:

```
DURDURULDU — Feature basarisiz oldu
Devam etmek icin: ./scripts/queue-runner.sh M1 --from 8
```

### Devam etmek

```bash
# Kaldigi yerden devam
./scripts/queue-runner.sh M1 --from 8

# Veya nohup ile
nohup ./scripts/queue-runner.sh M1 --from 8 > logs/queue-run/nohup.log 2>&1 &
```

### Durdurmak

```bash
# PID'yi bul
ps aux | grep queue-runner

# Durdur (mevcut feature tamamlanmaz)
kill <PID>

# Veya mevcut feature'in bitmesini bekle, sonra durdur
kill -TERM <PID>
```

## /queue-run ile karsilastirma

| | `/queue-run` | `queue-runner.sh` |
|---|---|---|
| Memory | Tek process, birikir | Her feature ayri process |
| Gece modu | Terminal acik kalmali | nohup/tmux ile arka planda |
| Uzun sureler | 5+ feature sonrasi riskli | Sinir yok |
| Hiz | Biraz daha hizli (context paylasimi) | Biraz daha yavas (her seferinde cold start) |
| Etkidesim | Claude icinden calistir | Terminal'den calistir |
| Ne zaman | Kisa isler (1-5 feature) | Uzun isler (gece, milestone, all) |

## Ornek senaryo

### Gece M1'i kodla

```bash
# Aksam 22:00'de
cd /path/to/ecommerce-mobile
nohup ./scripts/queue-runner.sh M1 > logs/queue-run/nohup.log 2>&1 &
echo "PID: $!"

# Sabah 08:00'de
tail -50 logs/queue-run/run-*.log

# Ornek cikti:
# ================================================================
# Kuyruk Ozeti
# ================================================================
# Islenen:   8 feature
# Basarili:  7 feature
# Basarisiz: 1 feature
# Atlanan:   0 feature
#
# Sonuclar:
#   OK  #8 - M1-01 (login-screen) — 45dk
#   OK  #9 - M1-02 (register-screen) — 38dk
#   OK  #10 - M1-03 (forgot-password) — 32dk
#   OK  #11 - M1-04 (home-screen) — 52dk
#   OK  #12 - M1-05 (category-browsing) — 41dk
#   OK  #13 - M1-06 (product-list) — 48dk
#   FAIL #14 - M1-07 (product-detail) — SwiftLint error
#
# Devam etmek icin: ./scripts/queue-runner.sh M1 --from 14
```
