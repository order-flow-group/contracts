# contracts

OrderFlow servislerinin arasındaki sözleşmelerin tek doğru kaynağı: senkron HTTP API'leri
OpenAPI 3.1 ile, asenkron event'ler AsyncAPI 3.0 ile burada tanımlanır. Servisler sözleşmeyi
buradan alır (contract-first); bir servise yeni bir alan, endpoint ya da event eklenmeden önce
bu repoya MR açılır. Repo kod çalıştırmaz; sözleşmeleri lint'ler, geriye dönük uyumsuz
(breaking) değişiklikleri yakalar ve sözleşmelerden doküman ile mock sunucu üretir.

## Mimarideki yeri

```
                 ┌──────────────────────────────┐
                 │  contracts (bu repo)         │
                 │  openapi/*.yaml  asyncapi/*  │
                 └──────┬───────────────┬───────┘
        kod üretimi /   │               │  event şemaları
        contract test   ▼               ▼
   order-service   inventory-service   payment-service   ai-*
          └──────── HTTP (OpenAPI) ─────┘
          └──────── RabbitMQ (AsyncAPI) ┘
```

Polyrepo kararının (K-02) en büyük riski servislerin birbirinden kopması; bu repo ve CI'daki
breaking change kontrolü o riski yönetir.

## Sözleşmeler

### HTTP (OpenAPI)

| Servis | Dosya | Method | Yol | Açıklama |
| --- | --- | --- | --- | --- |
| order-service | `openapi/order-service.yaml` | GET | `/health/live` | Süreç ayakta mı (bağımlılık kontrolü yok) |
| order-service | `openapi/order-service.yaml` | GET | `/health/ready` | Kendi DB/broker'ı hazır mı; değilse 503 |
| order-service | `openapi/order-service.yaml` | GET | `/metrics` | Prometheus metrikleri |

### Event'ler (AsyncAPI)

| Event | Kanal | Üreten | Tüketen |
| --- | --- | --- | --- |
| — | — | — | Faz 1'de eklenecek |

## Kurallar

- Değişiklik geriye uyumlu olmalı. Breaking değişiklik = yeni sürüm (ör. `/v2`, `order.created.v2`)
  ve ayrı MR.
- Her operasyonun `operationId`'si ve tag'i olur (kod üretimi buna dayanır).
- Health ve metrik uç noktaları kimlik doğrulamasızdır (`security: []`) ve sadece iç ağa açıktır.

## Komutlar

Araçlar sabit sürümlü Docker image'larıyla çalışır; lokalde sadece Docker ve `make` gerekir.

| Komut | Ne yapar |
| --- | --- |
| `make lint` | Spectral ile OpenAPI + AsyncAPI lint (uyarı da hata sayılır) |
| `make fmt` | Prettier ile YAML ve Markdown biçimleme |

## Sonra eklenecekler

- oasdiff breaking change kontrolü (`make test`) → F1 contract test
- Prism mock sunucu (`make run`) → ilk tüketici servis
- Doküman sitesi image'ı (Dockerfile, `make build`/`make docker`) → ihtiyaç olunca
- local-dev compose (`make up`/`make down`) → F0-11

## Lisans

Apache-2.0, bkz. [LICENSE](LICENSE).
