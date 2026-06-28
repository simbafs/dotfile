---
name: telegram-rich-message
description: >
  Use this skill when working with Telegram Bot API 10.1 rich_message (sendRichMessage/editMessageText).
  Covers known parser limitations — especially how `&` in URLs gets HTML-escaped to `&amp;` and the
  inline-keyboard workaround. Use whenever the user mentions Telegram rich messages, sendRichMessage,
  Bot API 10.1, or adding clickable links with query-string parameters (`&`) to structured Telegram
  messages containing tables, headings, or other rich blocks.
---

# Telegram Rich Message (`&` escaping)

## Core Problem

Telegram Bot API 10.1 `sendRichMessage` and `editMessageText` (with `rich_message` parameter) parse
the `markdown` or `html` content server-side. During parsing, **every `&` character inside a URL is
HTML-escaped to `&amp;`**. This happens regardless of whether you use:

- Markdown link syntax: `[text](url?param=1&param=2)`
- HTML `<a href>` tag in HTML mode
- Inline MarkdownV2 escape `\&` — Telegram converts `\` to `&#092;` first, then still escapes `&`

The result is that any Google-Maps-style URL like
`https://www.google.com/maps/search/?api=1&query=…` becomes
`https://www.google.com/maps/search/?api=1&amp;query=…` which is broken.

## What fails (tested combinations)

| Approach | Result |
|---|---|
| `rich_message.markdown` with `[text](url&param)` | ❌ `&` → `&amp;` |
| `rich_message.markdown_v2` key | ❌ 400 Bad Request (not supported) |
| `rich_message.html` with `<a href="url&param">` | ❌ `&` → `&amp;` |
| `rich_message` + `entities[text_link]` alongside | ❌ entities silently ignored |
| `rich_message` + `text` field + `entities` alongside | ❌ `text` and `entities` silently ignored |
| `rich_message.blocks` (pre-built JSON blocks) | ❌ 400 Bad Request |

## What works

### ✅ Inline keyboard button via `reply_markup`

The `reply_markup.inline_keyboard` button's `url` field is a raw JSON string that does **not** go
through rich-message content parsing. `&` is preserved exactly as sent.

```json
{
  "chat_id": 123456,
  "rich_message": {
    "markdown": "## Location - Category\n\n| Time | Status |\n|:-----|:-----|\n| 14:30 | Active |"
  },
  "reply_markup": {
    "inline_keyboard": [
      [
        {"text": "Open in Google Maps", "url": "https://www.google.com/maps/search/?api=1&query=Location+Name"}
      ]
    ]
  }
}
```

**Go example:**

```go
import "net/url"

mapsURL := "https://www.google.com/maps/search/?api=1&query=" + url.QueryEscape(location)

body := map[string]any{
    "chat_id":       chatID,
    "disable_notification": silent,
    "rich_message": map[string]string{
        "markdown": markdown,
    },
    "reply_markup": map[string]any{
        "inline_keyboard": [][]map[string]string{
            {{"text": "📍 Google Maps", "url": mapsURL}},
        },
    },
}
```

## Testing methodology

When debugging Telegram rich-message behavior, write a small standalone Go program that:

1. Constructs the JSON body for each hypothesis
2. Sends it via `http.Post` to `https://api.telegram.org/bot<TOKEN>/sendRichMessage`
3. Inspects both the HTTP response (for errors) and the rendered message in the Telegram client

Iterate on these combinations in isolation:
- Different `rich_message` keys (`markdown`, `html`, etc.)
- `entities` alongside `rich_message`
- `text` + `entities` alongside `rich_message`
- `reply_markup` with inline keyboard buttons
- Pre-built `blocks` vs markdown

This isolates whether the issue is Go-side (`json.Marshal` HTML-escaping of `&` → `\u0026`) or
Telegram-side (server parser behavior). Go's `json.Marshal` also HTML-escapes `&` by default, but
JSON decoders restore it — Telegram receives `&` correctly from JSON.

## Key insight

`rich_message` and `text`/`entities` are **mutually exclusive** in `sendRichMessage` and
`editMessageText`. The API processes only one content source. When `rich_message` is present,
`text` and `entities` are silently dropped.

The inline keyboard (`reply_markup`) is an independent message component and is the only reliable
way to attach a URL containing `&` to a rich-formatted message.
