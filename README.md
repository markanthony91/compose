# 🐳 AIKnow - Docker Stacks Hub

Este repositório centraliza a orquestração de serviços de infraestrutura, IA e automação da AIKnow.

## 🛠️ Stacks Gerenciadas

| Serviço | Descrição | Status | Configuração |
| :--- | :--- | :--- | :--- |
| **n8n** | Automação de workflows. | 🟢 Ativo | `.env.example` |
| **Supabase** | Backend as a Service. | 🟢 Ativo | `.env.example` |
| **Qdrant** | Banco de dados vetorial. | 🟢 Ativo | `setup.sh` + `.env` |
| **RAGFlow** | Motor de RAG. | 🔵 Configurado | `.env.example` |
| **Dify** | Plataforma LLM. | 🔵 Configurado | `setup.sh` (Auto-gen) |
| **Open-WebUI** | Interface para LLMs. | 🟢 Ativo | `.env.example` |

## 🚀 Como Utilizar

### 1. Configuração de Ambiente
A maioria das stacks utiliza arquivos `.env` para gerenciar portas e credenciais. 
- Algumas stacks possuem um script `setup.sh` que gera o `.env` automaticamente.
- Para configuração manual, copie o arquivo de exemplo:
  ```bash
  cp .env.example .env
  ```

### 2. Inicialização
```bash
cd stacks/nome-da-stack
./setup.sh # Se disponível
# OU
docker-compose up -d
```

## 📏 Regras e Padrões

1. **Persistência:** Volumes locais são usados para garantir que os dados sobrevivam a reinicializações.
2. **Segredos:** NUNCA commite arquivos `.env` reais com senhas de produção. Use sempre o `.env.example`.
3. **Rede:** Preferência pela rede externa `fedora-net`.

---
*Ecossistema de Infraestrutura Marcelo's Systems & AIKnow - 2026*
