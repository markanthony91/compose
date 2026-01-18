# Stack: AI-Database

Central de dados e mensagens otimizada para agentes de IA e arquiteturas RAG (Retrieval-Augmented Generation).

## Componentes

- **Postgres + pgvector:** Armazena dados relacionais e vetores de embeddings para busca semantica.
- **Redis:** Atua como broker de mensagens (filas) e cache de alta velocidade.
- **pgAdmin:** Ferramenta visual para administracao do banco de dados.

## Instalacao

```bash
sudo bash setup.sh
```

## Como usar para RAG

1. No seu app, conecte ao Postgres (`ai-postgres:5432`).
2. Ative a extensao vetorial:
   ```sql
   CREATE EXTENSION IF NOT EXISTS vector;
   ```
3. Crie tabelas com colunas do tipo `vector(1536)` (para modelos como OpenAI) ou `vector(768)` (para modelos locais).

## Como usar Filas

Conecte seu worker ao Redis (`ai-redis:6379`) usando a senha definida no `.env`. Use bibliotecas como `BullMQ` (Node.js) ou `Celery` (Python) para gerenciar as tarefas.
