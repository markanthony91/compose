# Beszel - Monitoring Stack

Monitoramento leve de recursos do host e containers Docker.

## Acesso
- **URL:** http://localhost:8090
- **Porta do Agent:** 45876

## Como Usar
1. Execute o setup: \`./setup.sh\`
2. Acesse a interface web e crie o primeiro usuario.
3. Clique em "Add System" para adicionar o host local.
4. O Agent ja esta rodando nesta stack, mas voce pode precisar configurar a \`KEY\` no \`.env\` se desejar autenticacao restrita entre Hub e Agent.

## Caracteristicas
- Visualizacao de CPU, RAM, Disco e Rede.
- Estatisticas detalhadas por container Docker.
- Alertas customizaveis.
- Historico de uso.
