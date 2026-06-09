# syntax=docker/dockerfile:1

# ─── Stage 1: Dependencies ───────────────────────────────────────────────────
FROM node:22-bookworm-slim AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# ─── Stage 2: Build ──────────────────────────────────────────────────────────
FROM deps AS builder
WORKDIR /app
COPY . .

# Runtime env placeholders — substituídos em deploy pelo forge via env-runtime.sh
# ou injetados diretamente pelo K8s como variáveis de ambiente.
ENV NEXT_PUBLIC_API_URL=__NEXT_PUBLIC_API_URL__
ENV NEXT_PUBLIC_APP_URL=__NEXT_PUBLIC_APP_URL__

RUN npm run build

# ─── Stage 3: Production ─────────────────────────────────────────────────────
FROM node:22-bookworm-slim AS runner

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends wget \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1001 nodejs \
    && useradd -u 1001 -g nodejs -s /bin/sh -m nextjs

WORKDIR /app

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
ENV NODE_ENV=production

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

CMD ["node", "server.js"]
