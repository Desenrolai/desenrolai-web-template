# desenrolai-web-template

Template base para frontends web da Desenrolai. Gerado pelo forge em `forge.desenrol.ai`.

## Stack

- Next.js 14 (App Router) + TypeScript strict
- Tailwind CSS v4 (`@import "tailwindcss"` + `@theme`)
- Node 22

## Começando

```bash
cp .env.example .env.local
# preencha NEXT_PUBLIC_API_URL e NEXT_PUBLIC_APP_URL

npm install
npm run dev
```

## Scripts

| Comando | Descrição |
|---------|-----------|
| `npm run dev` | Servidor de desenvolvimento |
| `npm run build` | Build de produção (standalone) |
| `npm run start` | Inicia o servidor de produção |
| `npm run lint` | ESLint |

## Health check

`GET /api/health` → `{ "status": "ok" }`

## Deploy

A imagem Docker é gerada e publicada automaticamente no GHCR via CI ao fazer push na branch padrão.

```
ghcr.io/desenrolai/<nome-do-repo>:main
```
