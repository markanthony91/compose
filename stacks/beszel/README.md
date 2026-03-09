# Beszel - Monitoring Stack

Stack local do Beszel para Docker Compose, ajustado para Ubuntu 22.04 no WSL2.

## Como usar

```bash
cd /home/marcelo/Sistemas/compose/stacks/beszel
./setup.sh
```

Se quiser outra porta:

```bash
./setup.sh 8095 http://localhost:8095
```

## Fluxo do setup

O script sobe o Hub primeiro e cria um `.env` com placeholders para o agent.

Depois do primeiro acesso ao Hub:

1. Crie um token em `/settings/tokens`.
2. Adicione um sistema manualmente.
3. Copie a public key mostrada pelo Hub.
4. Preencha `BESZEL_AGENT_TOKEN` e `BESZEL_AGENT_KEY` no `.env`.
5. Rode `./setup.sh` novamente.

Ao cadastrar o sistema no Hub, use o caminho abaixo como `Host / IP`:

```text
/beszel_socket/beszel.sock
```

## Healthchecks

Este stack inclui os healthchecks recomendados pela documentacao oficial:

- Hub: `/beszel health --url http://localhost:8090`
- Agent: `/agent health`

Os checks usam intervalo de `120s`, como sugerido pela documentacao para evitar overhead excessivo.

## Observacoes para WSL2

- O monitoramento reflete o ambiente Linux do WSL2, nao o Windows host.
- O stack depende de Docker e do plugin `docker compose` estarem funcionais dentro do Ubuntu.
