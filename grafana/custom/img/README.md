Place custom images here to override Grafana public assets (e.g., logo.png).
Grafana will mount this directory to `/usr/share/grafana/public/img`.

- To replace the main logo, add a file named `grafana_icon.svg` or `logo.png` depending on the Grafana version.
- After placing images, restart Grafana container: `docker compose restart grafana`.
