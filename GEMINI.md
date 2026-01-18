# GEMINI.md - Docker Compose Templates

Este arquivo fornece contexto para o Gemini Code ao trabalhar neste repositorio.

## Visao Geral do Projeto

**Docker Compose Templates** e um repositorio de arquivos docker-compose.yml padronizados para deploy de aplicacoes. Desenvolvido para facilitar o trabalho de analistas de suporte da **Aiknow Systems**.

- **Autor:** Mark - Aiknow Systems
- **Publico-alvo:** Analistas Junior de Suporte/Infraestrutura
- **Foco:** Templates prontos para producao com seguranca maxima e suporte a IA.

## Requisitos Obrigatorios para TODA Stack

Ao criar ou editar uma stack, o Gemini DEVE garantir:

### 1. Network Externa `llmserver`
Toda stack deve se conectar à rede `llmserver`:
```yaml
networks:
  llmserver:
    external: true
```

### 2. Atualizacao Automatica (Watchtower)
- Incluir sempre um serviço Watchtower focado na stack.
- Schedule: Domingo às 22:00.

### 3. Backup Incremental (Restic)
- Incluir serviço de backup automatizado para todos os volumes persistentes.

### 4. Versao Estavel e Segura
- **NUNCA** usar a tag `latest` para o serviço principal.
- Usar `security_opt: ["no-new-privileges:true"]`. 
- Limitar logs: `max-size: "10m"`, `max-file: "3"`.


## Estrutura do Projeto

```
compose/
├── GEMINI.md                    # Contexto para Gemini Code
├── CLAUDE.md                    # Contexto para Claude Code
├── README.md                    # Documentacao principal
├── stacks/                      # Stacks completas
└── templates/                   # Blocos YAML reutilizaveis
```

## Padrao de Compose Files (Template Gemini)

Sempre siga esta estrutura de metadados e YAML Anchors:

```yaml
################################################################################
# Stack: [nome]
# Autor: Gemini - Aiknow Systems
# Data: YYYY-MM-DD
# Versao: 1.0
# Acesso: tailscale funnel 443 http://localhost:[PORTA]
################################################################################

x-common: &common
  restart: unless-stopped
  networks:
    - llmserver
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"

services:
  app:
    image: [imagem]:[versao-especifica]
    container_name: [nome]-app
    <<: *common
    ports:
      - "${APP_PORT}:[PORTA_INTERNA]"
    volumes:
      - [nome]_data:/data
```

## Checklist de Deploy

- [ ] Arquivo `docker-compose.yml` segue o padrão de metadados.
- [ ] Arquivo `.env.example` criado com todas as variáveis (sem valores sensíveis).
- [ ] Rede `llmserver` configurada como externa.
- [ ] Watchtower e Backup incluídos.
- [ ] `README.md` da stack explica como ativar o Tailscale Funnel.

## Dicas para Gemini

1. **Pesquise a Versão:** Antes de sugerir uma imagem, verifique qual a última versão estável estável (evite bugs de dia zero).
2. **Modularidade:** Use YAML Anchors (`&common`, `*common`) para manter o arquivo limpo.
3. **Didática:** Explique no `README.md` da stack por que estamos usando Multihome (LAN/VPN).
4. **Próximos Passos:** Ao final do deploy, sempre mostre o comando do Tailscale para expor o app.

### 6. Gestao de Portas e Resolucao de Conflitos
Para evitar colisoes de portas entre stacks no mesmo host:
- **Registro:** A porta padrao de cada stack deve ser documentada no cabecalho do Compose e no README.
- **Regra 45-55:** Caso a porta padrao (ex: `XXXX`) esteja ocupada, a nova porta DEVE ser escolhida dentro do range `X[45-55]`.
  - *Exemplo:* Se a porta `3001` estiver em uso, a nova porta devera ser entre `3045` e `3055`.
- **Transparencia:** Sempre informe ao tecnico qual porta a stack esta utilizando atraves do arquivo `.env` e do output final.

### 7. Requisitos de Documentacao da Stack (README.md)
Todo `README.md` dentro de `stacks/[nome]/` DEVE conter:
- **Visao Geral:** O que e a aplicacao.
- **Configuracao (`.env`):** Explicacao de cada variavel.
- **Acesso e Seguranca:** Comandos Tailscale para expor o servico.
- **Proximos Passos:** Guia passo-a-passo apos o container subir (ex: criar usuario admin, configurar banco).
- **Troubleshooting:** Comandos basicos de log e reinicializacao.
### 5. Padrao de Escuta e Seguranca (Multihome)
- **Flexibilidade:** Os servicos devem ser acessiveis via Localhost (`127.0.0.1`), Rede Local (ex: `192.168.240.250`) e Tailscale.
- **Configuracao:** Use a variavel `BIND_IP` no `.env` para controlar a interface de escuta. O padrao devera ser `0.0.0.0` para permitir multihome.
- **Controle de Acesso:** O bloqueio de acessos externos (Internet Publica) deve ser feito via **Firewall (UFW)** no Host, permitindo apenas as subredes autorizadas (LAN e Tailscale).
