# Stack: Open WebUI (AI-Powered)

Interface web profissional para interacao com LLMs, integrada ao Ollama e otimizada com suporte a GPU NVIDIA.

## Requisitos

- **NVIDIA Docker Runtime:** Certifique-se de que o `nvidia-container-toolkit` esta instalado no host.
- **Ollama:** A stack assume que o Ollama esta rodando no host (`host.docker.internal:11434`).

## Instalacao

```bash
sudo bash setup.sh
```

## Gestao de Dados (Volume Externo)

Esta stack utiliza um volume externo chamado `openwebui_open-webui`. Isso garante que seus dados persistam mesmo se a stack for removida.

## Acesso

- **Porta Padrao:** 3000
- **Tailscale:** `sudo tailscale funnel --bg 3000`
