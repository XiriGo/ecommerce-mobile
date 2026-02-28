# Hemen Başlatılabilir Feature'lar

Backend durumu analiz edildi. 35 feature'dan **30'u** hemen başlatılabilir.

## Backend Durumu

### Mevcut (Kullanıma Hazır)
- **Standard Medusa Store API**: Products, Cart, Orders, Customers, Shipping, Categories
- **Custom Auth**: POST /auth/customer/emailpass (login, register), token refresh, sessions
- **Custom Store**: GET /store/vendors/:id, GET /store/brands, GET /store/products/:id/offers, specs

### Eksik (Backend'de henüz yok)
- Review/Rating modülü (product reviews)
- Q&A modülü (product questions & answers)
- Notification modülü (push notifications, in-app)
- Price Alert modülü (fiyat düşünce bildirim)
- Payment Methods yönetimi (Stripe provider setup gerekli)

---

## Batch Planı (Dependency sırasına göre)

### Batch 1 — M0 Foundation (Paralel, backend bağımsız)

5 feature, hepsi paralel çalışabilir. Backend'e hiç ihtiyaç yok.

```
/pipeline-run M0-01 app-scaffold
```
```
/pipeline-run M0-02 design-system
```
```
/pipeline-run M0-03 network-layer
```
```
/pipeline-run M0-04 navigation
```
```
/pipeline-run M0-05 di-setup
```

### Batch 2 — M0 Auth (Batch 1'e bağlı)

Backend auth endpoint'leri hazır. Token storage, auth state, interceptor.

```
/pipeline-run M0-06 auth-infrastructure
```

### Batch 3 — M1 Auth Screens + Home (Batch 2'ye bağlı, paralel)

4 feature paralel. Login/register endpoint'leri hazır, products/categories standard Medusa.

```
/pipeline-run M1-01 login-screen
```
```
/pipeline-run M1-02 register-screen
```
```
/pipeline-run M1-03 forgot-password
```
```
/pipeline-run M1-04 home-screen
```

### Batch 4 — M1 Browsing (Batch 3'e bağlı, paralel)

Standard Medusa product/category endpoint'leri kullanır.

```
/pipeline-run M1-05 category-browsing
```
```
/pipeline-run M1-06 product-list
```

### Batch 5 — M1 Detail + Search (Batch 4'e bağlı, paralel)

```
/pipeline-run M1-07 product-detail
```
```
/pipeline-run M1-08 product-search
```

### Batch 6 — M2 Commerce (Batch 5'e bağlı, paralel)

Cart = standard Medusa. Wishlist = local storage. Address = standard Medusa.

```
/pipeline-run M2-01 cart
```
```
/pipeline-run M2-02 wishlist
```
```
/pipeline-run M2-03 address-management
```

### Batch 7 — M2 Checkout Chain (Sıralı)

Her biri bir öncekine bağlı. Tüm endpoint'ler standard Medusa.

```
/pipeline-run M2-04 checkout-address
```
```
/pipeline-run M2-05 checkout-shipping
```
```
/pipeline-run M2-06 checkout-payment
```
```
/pipeline-run M2-07 order-confirmation
```

### Batch 8 — M3 Post-Purchase (Paralel)

Orders = standard Medusa. Profile = standard Medusa. Settings = local.
Vendor store = custom endpoint hazır (GET /store/vendors/:id).

```
/pipeline-run M3-01 order-list
```
```
/pipeline-run M3-03 user-profile
```
```
/pipeline-run M3-06 settings
```
```
/pipeline-run M3-08 vendor-store-page
```

### Batch 9 — M3 Order Detail (Batch 8'e bağlı)

```
/pipeline-run M3-02 order-detail
```

### Batch 10 — M4 Local Features (Paralel, backend bağımsız)

Hepsi tamamen local/native — backend gerekmez.

```
/pipeline-run M4-02 recently-viewed
```
```
/pipeline-run M4-04 share-product
```
```
/pipeline-run M4-05 app-onboarding
```

---

## BEKLEMEDE — Backend Gerekli (5 feature)

Bu feature'lar xirigo backend'de ilgili modüller tamamlanınca başlatılabilir:

| Feature | Beklediği Backend Modülü | Durum |
|---------|--------------------------|-------|
| M3-04 payment-methods | Stripe provider setup + saved cards API | ❌ Bekliyor |
| M3-05 notifications | Notification modülü + FCM/APNs entegrasyonu | ❌ Bekliyor |
| M3-07 product-reviews | Review/Rating modülü + API endpoint'leri | ❌ Bekliyor |
| M4-01 product-qna | Q&A modülü + API endpoint'leri | ❌ Bekliyor |
| M4-03 price-alerts | Price Alert modülü + API endpoint'leri | ❌ Bekliyor |

---

## Özet

| Kategori | Feature Sayısı | Durum |
|----------|---------------|-------|
| Hemen başlatılabilir | **30** | Backend hazır veya gerekmez |
| Backend bekliyor | **5** | Eksik modüller var |
| **Toplam** | **35** | |

| Batch | Feature Sayısı | Tahmini Paralellik |
|-------|---------------|-------------------|
| Batch 1 (M0 Foundation) | 5 | 5 paralel |
| Batch 2 (M0 Auth) | 1 | sıralı |
| Batch 3 (M1 Auth+Home) | 4 | 4 paralel |
| Batch 4 (M1 Browse) | 2 | 2 paralel |
| Batch 5 (M1 Detail) | 2 | 2 paralel |
| Batch 6 (M2 Commerce) | 3 | 3 paralel |
| Batch 7 (M2 Checkout) | 4 | sıralı chain |
| Batch 8 (M3 Post-Purchase) | 4 | 4 paralel |
| Batch 9 (M3 Detail) | 1 | sıralı |
| Batch 10 (M4 Local) | 3 | 3 paralel |
| Beklemede | 5 | — |
