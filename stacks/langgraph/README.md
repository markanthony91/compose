# Stack: LangGraph Server

Motor de execução para grafos de agentes. Utiliza um banco de dados Postgres dedicado para persistência de threads (memória de longa duração para conversas).

## Como Funciona

1. O **LangGraph Server** lê seus grafos definidos em Python.
2. O **Postgres** salva o estado de cada conversa (thread_id).
3. Você pode conectar seu Gradio ou interface web via API na porta 8123.

## Instalacao

```bash
sudo bash setup.sh
```

## Integracao com Agentes

No seu código Python, você pode apontar para este servidor para rodar os grafos de forma distribuída. O servidor já está configurado para acessar o Ollama no host (`host.docker.internal`).

## Persistencia

Os dados das conversas e o estado dos agentes ficam salvos no volume local em `./data/db`.
