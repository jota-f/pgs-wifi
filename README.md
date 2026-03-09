# PGSwifi — Monitoramento

Este repositório contém uma stack Docker Compose para um servidor de monitoramento que usa:
- Eclipse Mosquitto (MQTT broker)
- Telegraf (coletor de métricas, lê MQTT e envia para InfluxDB)
- InfluxDB 2.x (timeseries DB)
- Grafana (visualização)

Objetivo: fornecer um template que possa ser reaproveitado em outros servidores.

## Como usar este repositório para montar um servidor pronto

## Rápido - configurar e subir


Este guia passo-a-passo assume que você tem um servidor com Docker e Docker Compose instalados.

1) Clonar o repositório

```powershell
git clone <URL-DO-REPO>
cd pgswifi
```

No Linux/macOS:

```bash
git clone <URL-DO-REPO>
cd pgswifi
```

2) Pré-requisitos
- Docker e Docker Compose instalados e funcionando
- Acesso com permissões para executar containers (usuário docker ou root)

3) Preparar variáveis de ambiente
- Copie o arquivo de exemplo e edite os valores sensíveis:

```powershell
copy .env.example .env
# abra .env no editor e substitua os valores change_me_* por senhas/tokens seguros
```

No Linux/macOS:

```bash
cp .env.example .env
# abra .env no editor e substitua os valores change_me_* por senhas/tokens seguros
```

4) Gerar arquivos de configuração (templates)
- No Windows use o script fornecido para gerar `configs/telegraf.conf` e `grafana/provisioning/datasources/influxdb.yml` a partir dos templates:

```powershell
.\scripts\render-templates.ps1
```

No Linux/macOS com envsubst:

```bash
envsubst < configs/telegraf.conf.tpl > configs/telegraf.conf
envsubst < grafana/provisioning/datasources/influxdb.yml.tpl > grafana/provisioning/datasources/influxdb.yml
```
(Se preferir, instale `gettext` para obter `envsubst` em algumas distribuições: ex. `sudo apt install gettext`.)

5) Iniciar a stack

```powershell
docker compose down
docker compose up -d
```

6) Verificar que os serviços subiram
- InfluxDB: acesse http://localhost:8086
- Grafana: acesse http://localhost:3000 (usuário/senha padrão do Grafana se aplicável)
- Mosquitto: porta 1883

7) Grafana com dashboards e logo
- Este repositório já contém a pasta `grafana/` com dados, dashboards e assets. O arquivo `grafana/public/grafana_icon.svg` é disponibilizado no container e será usado como logo quando aplicável.
- Se você preferir substituir a logo ou adicionar dashboards manualmente, coloque os arquivos em `grafana/public` ou `grafana/provisioning/dashboards/` conforme desejar.


8) Backup e persistência
- Os dados persistem em `grafana/data`, `influxdb/data` e `mosquitto/data`. Faça backup desses diretórios antes de mover o servidor.

---

### Dicas para primeira instalação/execução

1. **Crie os diretórios de dados (se não existirem):**
   ```sh
   mkdir -p grafana/data influxdb/data mosquitto/data
   ```

2. **Garanta que as portas 1883 (MQTT), 8086 (InfluxDB) e 3000 (Grafana) estejam livres.**
   - No Linux: `sudo lsof -i :1883 -i :8086 -i :3000`
   - No Windows: `netstat -ano | findstr ":1883"`

3. **(Linux) Instale o envsubst se necessário:**
   ```sh
   sudo apt update && sudo apt install gettext
   ```

4. **Baixe as imagens mais recentes antes de subir:**
   ```sh
   docker compose pull
   ```

5. **Se esquecer algum token/senha:**
   - Gere um novo hash com `mosquitto_passwd` e atualize o arquivo.
   - Para InfluxDB, gere novo token via interface web/admin.

6. **Se der erro, veja os logs de todos os serviços:**
   ```sh
   docker compose logs --tail=50 mosquitto telegraf influxdb grafana
   ```

7. **Healthcheck manual dos serviços:**
   - Mosquitto: `docker exec -it mosquitto mosquitto_sub -h localhost -p 1883 -t '#' -u <usuario> -P <senha>`
   - InfluxDB: acesse http://localhost:8086
   - Grafana: acesse http://localhost:3000

8. **Firewall:**
   - Certifique-se de liberar as portas necessárias no firewall do servidor.

---



## Resolução de Problemas (Troubleshooting)

### Mosquitto: Permissões do arquivo de senhas
O arquivo `configs/mosquitto.passwd` **precisa ser protegido** para que o Mosquitto aceite autenticação. Se aparecerem avisos como:

```
Warning: File .../mosquitto.passwd has world readable permissions. Future versions will refuse to load this file.
Warning: File .../mosquitto.passwd owner is not root. Future versions will refuse to load this file.
```

Corrija com:

```sh
chmod 0700 configs/mosquitto.passwd
chown root:root configs/mosquitto.passwd
```

Se estiver rodando via Docker Compose, pode ser necessário rodar esses comandos no host e reiniciar o container:

```sh
docker compose restart mosquitto
```

### Gerar ou atualizar senha de usuário MQTT
O utilitário `mosquitto_passwd` é necessário para criar ou atualizar usuários no arquivo de senhas. Se não existir no seu sistema, instale:

**Debian/Ubuntu:**
```sh
apt update
apt install mosquitto
# (o utilitário vem no pacote principal, não no mosquitto-clients)
```

Para adicionar ou atualizar o usuário `telegraf`:
```sh
mosquitto_passwd -b configs/mosquitto.passwd telegraf SUASENHA
```
Isso mantém os outros usuários intactos.

### Telegraf: Erro "not Authorized" no MQTT
Se o Telegraf mostrar erro:

```
Error running agent: starting input inputs.mqtt_consumer: not Authorized
```

Verifique:
- O usuário e senha no `.env` batem com o hash do arquivo `mosquitto.passwd`
- O arquivo de senhas está com permissões corretas (veja acima)
- O Mosquitto foi reiniciado após atualizar o arquivo

### Telegraf: Erro de DNS ou conexão
Se aparecer:

```
network Error : dial tcp: lookup mosquitto on 127.0.0.11:53: server misbehaving
```

Isso geralmente é temporário (ordem de inicialização dos containers). O Telegraf tentará reconectar automaticamente.

### Checklist rápido para debug MQTT
- [ ] Usuário e senha do Telegraf estão corretos no `.env` e no `mosquitto.passwd`
- [ ] Permissões do `mosquitto.passwd` corrigidas (`chmod 0700`, `chown root:root`)
- [ ] Mosquitto reiniciado após alterar senhas
- [ ] Telegraf reiniciado após alterar configs
- [ ] Use `docker compose logs mosquitto` e `docker compose logs telegraf` para investigar

---





docker compose up -d
docker compose down
docker compose up -d

