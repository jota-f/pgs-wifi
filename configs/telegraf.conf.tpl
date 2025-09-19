## Template: telegraf.conf.tpl
## Use envsubst to render this template into configs/telegraf.conf
## Example: envsubst < telegraf.conf.tpl > telegraf.conf

[agent]
  interval = "10s"
  metric_buffer_limit = 10000

[[outputs.influxdb_v2]]
  urls = ["http://influxdb:8086"]
  # Token is injected from environment
  token = "${INFLUX_TELEGRAF_TOKEN}"
  organization = "${INFLUX_INIT_ORG}"
  bucket = "${INFLUX_INIT_BUCKET}"

[[inputs.mqtt_consumer]]
  servers = ["tcp://mosquitto:1883"]
  topics = ["/#","/"]
  data_format = "json"
  username = "${TELEGRAF_MQTT_USERNAME}"
  password = "${TELEGRAF_MQTT_PASSWORD}"

[[processors.rename]]
  [[processors.rename.replace]]
    field = "vasao"
    dest = "vazao"
