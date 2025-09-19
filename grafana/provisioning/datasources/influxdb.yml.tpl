apiVersion: 1

datasources:
  - name: InfluxDB
    type: influxdb
    url: http://influxdb:8086
    access: proxy
    isDefault: true
    version: 2
    withCredentials: false
    jsonData:
      httpMode: "GET"
      orgId: "${INFLUX_INIT_ORG}"
      defaultBucket: "${INFLUX_INIT_BUCKET}"
    secureJsonData:
      token: "${INFLUX_GRAFANA_TOKEN}"
