#!/usr/bin/env bash
# render-templates.sh
# Renderiza templates com placeholders ${VAR} para arquivos finais usando variáveis do .env
# Uso: ./scripts/render-templates.sh [-f] [-e path/to/.env]

set -euo pipefail

FORCE=0
ENVFILE=".env"

while getopts ":fe:" opt; do
  case ${opt} in
    f ) FORCE=1 ;;
    e ) ENVFILE="$OPTARG" ;;
    \? ) echo "Uso: $0 [-f] [-e path/to/.env]"; exit 1 ;;
  esac
done

if [ ! -f "$ENVFILE" ]; then
  echo "Arquivo de ambiente não encontrado: $ENVFILE"
  exit 1
fi

# Carrega .env em variáveis de ambiente, lidando com quotes
while IFS= read -r line || [ -n "$line" ]; do
  # Ignora comentários e linhas vazias
  [[ "$line" =~ ^\s*# ]] && continue
  [[ "$line" =~ ^\s*$ ]] && continue
  if [[ "$line" == *"="* ]]; then
    name="${line%%=*}"
    value="${line#*=}"
    # Trim spaces
    name="$(echo "$name" | sed -e 's/^\s*//' -e 's/\s*$//')"
    value="$(echo "$value" | sed -e 's/^\s*//' -e 's/\s*$//')"
    # Remove surrounding quotes if present
    if [[ ( "$value" == '"'*'"' ) || ( "$value" == "'"*"'" ) ]]; then
      value="${value:1:${#value}-2}"
    fi
    export "$name=$value"
  fi
done < "$ENVFILE"

render() {
  local tpl="$1"
  local out="$2"
  if [ ! -f "$tpl" ]; then
    echo "Template não encontrado: $tpl"
    return 1
  fi
  mkdir -p "$(dirname "$out")"
  if [ -f "$out" ] && [ "$FORCE" -eq 0 ]; then
    echo "Pulando $out (já existe). Use -f para forçar sobrescrita."
    return 0
  fi

  if command -v envsubst >/dev/null 2>&1; then
    envsubst < "$tpl" > "$out"
  else
    # Fallback: usa perl para substituir ${VAR} com valor do ambiente
    perl -0777 -pe 's/\$\{([A-Za-z0-9_]+)\}/(defined $ENV{$1} ? $ENV{$1} : "")/ge' "$tpl" > "$out"
  fi
  echo "Rendered: $tpl -> $out"
}

# Lista de templates -> outputs
render "configs/telegraf.conf.tpl" "configs/telegraf.conf"
render "grafana/provisioning/datasources/influxdb.yml.tpl" "grafana/provisioning/datasources/influxdb.yml"

echo "Pronto. Agora rode: docker compose up -d"
