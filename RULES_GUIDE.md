# Rules Guide

Этот файл описывает, где находится главный источник правил в проекте и как с ним работать.

## Главный источник правил

Главный источник правил для обоих клиентов находится в папке:

`rules/ClashVerge/*.yaml`

Именно эти файлы нужно редактировать вручную:

- `rules/ClashVerge/ai.yaml`
- `rules/ClashVerge/social.yaml`
- `rules/ClashVerge/work.yaml`
- `rules/ClashVerge/streaming.yaml`
- `rules/ClashVerge/voice_ports.yaml`
- `rules/ClashVerge/torrents.yaml`
- `rules/ClashVerge/storage.yaml`
- `rules/ClashVerge/reject.yaml`

## Как это связано с двумя клиентами

### Clash-образные клиенты

Clash-образные клиенты используют правила напрямую из `.yaml`.

Основной конфиг:

- `settings/ClashVerge.yaml`

### Shadowrocket

Shadowrocket использует правила в формате `.list`.

Эти `.list` файлы не являются главным источником и генерируются автоматически из `rules/ClashVerge/*.yaml`.

Сгенерированные файлы:

- `rules/ShadowRocket/ai.list`
- `rules/ShadowRocket/social.list`
- `rules/ShadowRocket/work.list`
- `rules/ShadowRocket/streaming.list`
- `rules/ShadowRocket/voice_ports.list`
- `rules/ShadowRocket/torrents.list`
- `rules/ShadowRocket/storage.list`
- `rules/ShadowRocket/reject.list`

Основной конфиг:

- `settings/shadowrocket.conf`

## Автоматизация

Конвертация `.yaml` в `.list` выполняется скриптом:

- `scripts/sync_shadowrocket_lists.sh`

На GitHub это также поддерживается автоматически через workflow:

- `.github/workflows/sync-shadowrocket-lists.yml`

После изменения файлов в `rules/ClashVerge/*.yaml` нужно обновить `.list`:

```bash
bash scripts/sync_shadowrocket_lists.sh
```

Смысл схемы такой:

1. Редактируем только `rules/ClashVerge/*.yaml`.
2. Скрипт пересобирает `rules/ShadowRocket/*.list`.
3. Clash использует `.yaml`, Shadowrocket использует `.list`.
4. Если `.list` случайно отредактировали вручную и они разошлись с `.yaml`, GitHub Action пересоберёт `.list` заново из `.yaml` и приведёт их обратно к источнику истины.

## Формат правил

Во всех `rules/ClashVerge/*.yaml` используется такой шаблон:

```yaml
payload:
  - DOMAIN-SUFFIX,example.com
  - DOMAIN,api.example.com
  - IP-CIDR,203.0.113.0/24
```

Каждая строка в `payload` — это одно правило.

## Основные типы правил

### `DOMAIN-SUFFIX`

Совпадение по домену и всем его поддоменам.

Пример:

```yaml
- DOMAIN-SUFFIX,example.com
```

Что совпадёт:

- `example.com`
- `api.example.com`
- `cdn.example.com`

Когда использовать:

- если нужно покрыть весь сервис целиком;
- если у сервиса много поддоменов.

### `DOMAIN`

Совпадение только по точному доменному имени.

Пример:

```yaml
- DOMAIN,api.example.com
```

Что совпадёт:

- `api.example.com`

Что не совпадёт:

- `example.com`
- `cdn.api.example.com`

Когда использовать:

- если нужен только один конкретный хост;
- если не хочется затронуть весь домен.

### `IP-CIDR`

Совпадение по диапазону IPv4-адресов.

Пример:

```yaml
- IP-CIDR,203.0.113.0/24
```

Что это значит:

- будет совпадать весь диапазон от `203.0.113.0` до `203.0.113.255`

Когда использовать:

- если сервис ходит напрямую по IP;
- если доменных правил недостаточно;
- если нужно покрыть выделенную сеть сервиса.

### `IP-CIDR6`

Совпадение по диапазону IPv6-адресов.

Пример:

```yaml
- IP-CIDR6,2001:db8::/32
```

Когда использовать:

- если сервис использует IPv6;
- если нужно явно описать IPv6-сеть.

## Что выбирать на практике

Обычно порядок такой:

1. Сначала пробуем `DOMAIN-SUFFIX`.
2. Если нужен только один хост, используем `DOMAIN`.
3. Если сервис использует прямые IP или медиа-сети, добавляем `IP-CIDR`.
4. Если есть IPv6-трафик, при необходимости добавляем `IP-CIDR6`.

## Примеры

### Проксировать весь сервис

```yaml
payload:
  - DOMAIN-SUFFIX,example.com
```

### Проксировать только API-хост

```yaml
payload:
  - DOMAIN,api.example.com
```

### Добавить IP-сеть сервиса

```yaml
payload:
  - DOMAIN-SUFFIX,example.com
  - IP-CIDR,203.0.113.0/24
```

### Заблокировать сервис

Для блокировок правила добавляются в:

- `rules/ClashVerge/reject.yaml`

Пример:

```yaml
payload:
  - DOMAIN-SUFFIX,example.com
  - DOMAIN,api.example.com
  - IP-CIDR,203.0.113.0/24
```

В `ClashVerge.yaml` этот набор подключён как `REJECT`, а в `shadowrocket.conf` — тоже как `REJECT`.

## Важное правило проекта

Не редактируйте вручную файлы:

- `rules/ShadowRocket/*.list`

Их всегда нужно пересобирать из:

- `rules/ClashVerge/*.yaml`

Иначе `.yaml` и `.list` начнут расходиться.
