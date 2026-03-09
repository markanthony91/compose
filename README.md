# 🐳 AIKnow - Docker Stacks Hub

Este repositório centraliza a orquestração de serviços de infraestrutura, IA e automação da AIKnow.

## 📁 Detalhamento das Stacks

Abaixo, a descrição técnica do que você encontrará em cada pasta dentro de `stacks/`:

### 🤖 Inteligência Artificial & Agentes
- **`dify/`**: Plataforma completa para desenvolvimento de aplicações LLM. Inclui orquestração de prompts e fluxos de IA.
- **`ragflow/`**: Motor especializado em RAG (Retrieval-Augmented Generation), focado em extração de conhecimento de documentos complexos.
- **`open-webui/`**: Interface de chat avançada para interagir com modelos locais (Ollama) e APIs externas.
- **`langgraph/`**: Infraestrutura para execução de agentes de IA com lógica de grafos (cíclicos e acíclicos).
- **`autogen-studio/`**: Ambiente visual para prototipagem de sistemas multi-agentes baseados no framework AutoGen.

### ⚙️ Automação & Backend
- **`n8n/`**: Motor de automação de workflows "low-code". Contém arquivos de teste (`goss.yaml`) para validar a saúde do serviço.
- **`supabase/`**: Backend-as-a-Service open-source. Inclui Postgres, autenticação e APIs REST automáticas.
- **`ai-database/`**: Configurações de banco de dados otimizadas para armazenamento de vetores e metadados de IA.
- **`qdrant/`**: Banco de dados vetorial de alta performance, essencial para buscas semânticas e memória de longo prazo para IAs.

### 🛡️ Monitoramento & Infraestrutura
- **`uptime-kuma/`**: Painel de monitoramento de status para sites e APIs com notificações em tempo real.
- **`beszel/`**: Stack de monitoramento leve com `setup.sh` para Ubuntu 22.04 no WSL2, incluindo healthchecks do Hub e do Agent.
- **`kopia/`**: Gerenciador de backups criptografados e incrementais para proteger os volumes do Docker.

## 🚀 Como Utilizar

### 1. Configuração de Ambiente
Cada stack possui um arquivo `.env.example`. Antes de iniciar:
```bash
cd stacks/nome-da-stack
cp .env.example .env
```
*Alguns serviços como **Dify** e **Qdrant** possuem um `setup.sh` que faz isso automaticamente.*

### 2. Inicialização
```bash
docker-compose up -d
```

### 3. Setup Guiado do Beszel
Para a stack do Beszel:
```bash
cd stacks/beszel
./setup.sh
```

O script sobe o Hub primeiro, cria o `.env` com placeholders e so ativa o Agent quando `BESZEL_AGENT_TOKEN` e `BESZEL_AGENT_KEY` forem preenchidos.

## 📏 Regras e Padrões
1. **Persistência:** Dados críticos estão mapeados em pastas locais para facilitar backups via Kopia.
2. **Segurança:** O Bitbucket contém apenas exemplos. Senhas reais ficam apenas no ambiente local.

---
*Ecossistema de Infraestrutura Marcelo's Systems & AIKnow - 2026*
