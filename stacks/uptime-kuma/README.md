# Stack: Uptime Kuma

O **Uptime Kuma** e uma ferramenta de monitoramento auto-hospedada facil de usar, que permite monitorar o tempo de atividade de sites, servidores e containers Docker com alertas integrados.

## Configuracao (.env)

| Variavel | Descricao | Padrao |
|----------|-----------|--------|
| UPTIME_KUMA_PORT | Porta local no host para o servico | 3001 |

## Como Rodar

1. Copie o exemplo: `cp .env.example .env`
2. Suba a stack: `docker compose up -d`

## Acesso e Seguranca (Tailscale)

Por padrao, o Uptime Kuma escuta apenas em `127.0.0.1`. Escolha como deseja expor:

- **Privado (Apenas na VPN):** `sudo tailscale serve --bg 3001`
- **Publico (Internet):** `sudo tailscale funnel --bg 3001`

---

## 🎯 Proximos Passos (Guia do Tecnico)

Apos subir o container e acessar a URL, siga estes passos:

1. **Criar Conta Admin:** Defina um usuario e senha fortes imediatamente.
2. **Configurar Notificacoes:** 
   - Va em *Settings > Notifications*.
   - Adicione seu bot do Telegram, Discord ou canal de e-mail.
3. **Adicionar Monitores:**
   - Clique em *Add New Monitor*.
   - Para monitorar containers locais, use o tipo *Docker Container*.
   - Use o nome do container (ex: `ollama`) gracas a rede `llmserver`.

---

## Troubleshooting

- **Ver Logs:** `docker logs -f uptime-kuma`
- **Reiniciar:** `docker compose restart`

## Instalacao Simplificada (Recomendado)

Esta stack possui um script de instalacao automatica que configura as portas e o Tailscale para voce:

```bash
sudo bash setup.sh "Uptime Kuma" 3001
```
