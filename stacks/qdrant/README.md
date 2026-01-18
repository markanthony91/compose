# Stack: Qdrant Vector DB

Banco de dados vetorial de alta performance para armazenamento de embeddings e busca semantica (RAG).

## Instalacao

```bash
sudo bash setup.sh
```

## Integracao com Open WebUI

Para que o Open WebUI use este Qdrant, configure as seguintes variaveis no `.env` do Open WebUI:

- `VECTOR_DB=qdrant`
- `QDRANT_URI=http://qdrant:6333` (Usando o nome DNS interno da rede llmserver)

## Persistencia

Os dados estao salvos localmente na pasta `./storage` dentro deste diretorio.
