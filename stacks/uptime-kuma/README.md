# Stack: Uptime Kuma

Monitoramento de uptime com interface moderna, suporte a diversos tipos de monitoramento e alertas (Telegram, Discord, etc).

## Como Rodar

1. Copie o arquivo .env.example para .env
2. Suba o container:
   ```bash
   docker compose up -d
   ```

## Acesso e Seguranca

Por seguranca, esta stack escuta apenas em `127.0.0.1`. Para acessar externamente de forma segura, use o Tailscale:

### Via Tailscale Funnel (Publico)
```bash
sudo tailscale funnel --bg 3001
```

### Via Tailscale Serve (Privado na VPN)
```bash
sudo tailscale serve --bg 3001
```

## Caracteristicas

- **Rede:** Integrado a rede `llmserver`.
- **Atualizacao:** Watchtower incluso para manter a stack atualizada.
- **Monitoramento Docker:** Volume do docker.sock montado (read-only) para monitorar outros containers.

## Gestao de Portas

- **Porta Padrao:** 3001
- **Conflito?** Caso a porta 3001 esteja em uso, use o range **3045 a 3055** no seu arquivo `.env`.
