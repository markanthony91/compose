# 🐳 AIKnow - Docker Stacks Hub

Este repositório centraliza a orquestração de serviços de infraestrutura, IA e automação da AIKnow. Cada diretório em `stacks/` representa um serviço isolado e configurado para o ambiente Fedora/Docker.

## 🛠️ Stacks Gerenciadas

| Serviço | Descrição | Status |
| :--- | :--- | :--- |
| **n8n** | Automação de workflows baseada em nós. | 🟢 Ativo |
| **Supabase** | Backend as a Service (Database, Auth, Storage). | 🟢 Ativo |
| **Qdrant** | Banco de dados vetorial para aplicações de IA. | 🟢 Ativo |
| **RAGFlow** | Motor de RAG para compreensão profunda de documentos. | 🔵 Configurado |
| **Dify** | Plataforma de desenvolvimento de aplicações LLM. | 🔵 Configurado |
| **Open-WebUI** | Interface amigável para interação com LLMs locais. | 🟢 Ativo |
| **LangGraph** | Orquestração de agentes cíclicos e complexos. | 🟡 Dev |
| **AutoGen Studio** | Interface para agentes multi-agentes da Microsoft. | 🟡 Dev |
| **Beszel** | Monitoramento leve de recursos do servidor. | 🟢 Ativo |
| **Kopia** | Ferramenta de backup incremental e criptografado. | 🟢 Ativo |
| **Uptime Kuma** | Monitoramento de disponibilidade de serviços. | 🟢 Ativo |

## 🚀 Como Utilizar

Cada stack possui seu próprio `docker-compose.yml` e, em muitos casos, um script `setup.sh` para facilitar a inicialização.

### Exemplo de Inicialização:
1. Entre na pasta da stack desejada:
   ```bash
   cd stacks/qdrant
   ```
2. Execute o setup ou suba o compose:
   ```bash
   docker-compose up -d
   ```

## 📏 Regras e Padrões

1. **Persistência:** Todos os dados persistentes devem ser mapeados em volumes locais ou pastas nomeadas para garantir a segurança dos dados.
2. **Rede:** Os serviços utilizam preferencialmente a rede `fedora-net` para comunicação inter-container.
3. **Segurança:** Variáveis sensíveis devem ser mantidas em arquivos `.env` (não versionados no Bitbucket quando contiverem segredos reais).

---
*Ecossistema de Infraestrutura Marcelo's Systems & AIKnow - 2026*
