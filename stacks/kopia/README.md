# Stack: Kopia Backup Server

Servidor de backup criptografado com interface Web para gestao de snapshots e politicas de retencao.

## Instalacao Simplificada

```bash
sudo bash setup.sh
```

## Proximos Passos (Guia do Tecnico)

1. **Criar Repositorio:** No primeiro acesso, escolha o local `/repository` (que voce mapeou no setup).
2. **Definir Senha do Repositorio:** Use uma senha mestre diferente da senha do admin.
3. **Configurar Snapshot:** Adicione o caminho `/data_to_backup` para proteger seus dados.
4. **Politica de Retencao:** Configure quantos backups deseja manter (ex: 7 diarios, 4 semanais).

## Troubleshooting

- **Logs:** `docker logs -f kopia-server`
- **Permissoes:** Garanta que a pasta do seu SSD/NVMe tenha permissao de escrita.
