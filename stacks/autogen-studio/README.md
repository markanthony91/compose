# Stack: AutoGen Studio

Interface visual da Microsoft para criar, gerenciar e testar agentes de IA que conversam entre si para resolver tarefas complexas.

## Instalacao

```bash
sudo bash setup.sh
```

## Como usar com Ollama (Local)

1. No AutoGen Studio, va em *Models*.
2. Adicione um novo modelo:
   - **Model Name:** `llama3.2` (ou o que voce tiver no Ollama).
   - **API Key:** `NULL` (ou qualquer valor).
   - **Base URL:** `http://host.docker.internal:11434/v1`.
3. Va em *Agents* e associe esse modelo aos seus agentes.

## Caracteristicas

- **Fluxo de Trabalho:** Permite criar 'Skills' (Python) que os agentes podem usar.
- **Persistencia:** Todos os agentes e fluxos sao salvos na pasta `./data`.
- **Rede:** Integrado a rede `llmserver`.
