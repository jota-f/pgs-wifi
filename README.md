# PGSwifi — Monitoramento

Este repositório contém uma stack Docker Compose para um servidor de monitoramento que usa:
- Eclipse Mosquitto (MQTT broker)
- Telegraf (coletor de métricas, lê MQTT e envia para InfluxDB)
- InfluxDB 2.x (timeseries DB)
- Grafana (visualização)

Objetivo: fornecer um template que possa ser reaproveitado em outros servidores.



## Como usar este repositório para montar um servidor pronto

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





## Rápido - configurar e subir
1. Copie o arquivo de exemplo e edite os valores sensíveis:

```powershell
copy .env.example .env
# Edite .env no seu editor e substitua os valores change_me_* pelos tokens/senhas desejados
```

No Linux/macOS:

```bash
cp .env.example .env
# Edite .env com seu editor favorito: nano .env | vim .env | code .env
```

2. Gere os arquivos de configuração a partir dos templates (Windows PowerShell):

```powershell
# Na raiz do projeto
.\scripts\render-templates.ps1
# Use -Force se quiser sobrescrever arquivos já existentes
.\scripts\render-templates.ps1 -Force
```

No Linux/macOS (com envsubst instalado):

```bash
envsubst < configs/telegraf.conf.tpl > configs/telegraf.conf
envsubst < grafana/provisioning/datasources/influxdb.yml.tpl > grafana/provisioning/datasources/influxdb.yml
```

3. Suba a stack:

```powershell
docker compose down;
docker compose up -d
```

No Linux/macOS:

```bash
docker compose down
docker compose up -d
```

