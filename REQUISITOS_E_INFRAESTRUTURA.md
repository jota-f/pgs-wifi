# Requisitos de Sistema e Infraestrutura (PGS Plus)

Este documento descreve os requisitos de hardware, rede, segurança e infraestrutura necessários para a implantação e operação segura do servidor de monitoramento do **TBi PGS Plus**.

---

## 1. Dimensionamento de Hardware

Para implantações típicas (dezenas de sensores a centenas de sensores), a stack de monitoramento é extremamente otimizada e consome poucos recursos.

### Requisitos Mínimos (Produção)
*   **Processador (CPU):** 1 vCPU / Core
*   **Memória RAM:** 2 GB
*   **Armazenamento:** SSD ou NVMe de 20 GB a 50 GB.
*   **Sistema Operacional:** Debian / Ubuntu (Recomendado), Windows Server, CentOS, RHEL ou macOS.
*   **Ambiente de Execução:** Docker Engine v20.10+ e Docker Compose v2.x+.

> [!IMPORTANT]
> **Por que SSD é obrigatório?** Bancos de dados de séries temporais como o InfluxDB executam fluxos contínuos de escrita e leitura. Discos mecânicos convencionais (HDDs) podem sofrer gargalos graves de I/O a longo prazo.

### Requisitos Recomendados (Expansão ou Alta Disponibilidade)
Se houver centenas de sensores ou alto volume de acessos simultâneos ao Grafana:
*   **Processador (CPU):** 2 vCPUs ou mais
*   **Memória RAM:** 4 GB ou mais

---

## 2. Sincronização de Horário (NTP) - Obrigatório

Como o **InfluxDB** é um banco de dados de séries temporais (*time-series*), todos os registros dependem de carimbos de data/hora (*timestamps*) de alta precisão. Por este motivo, **tanto o servidor quanto os sensores de medição precisam estar sincronizados via NTP** (seja utilizando servidores públicos na internet ou um servidor NTP local na rede interna).

### Requisitos de NTP:
1.  **Sensores e Equipamentos:** Devem estar obrigatoriamente sincronizados via NTP para garantir que a coleta e envio das métricas ocorram com o carimbo de tempo correto.
2.  **Servidor Host:** O sistema operacional que executa os containers Docker também deve ter o serviço NTP ativado (como `chrony` ou `systemd-timesyncd` no Linux, ou o serviço de Horário do Windows).
3.  **Servidores de referência recomendados:**
    *   *NTP Público (se houver acesso à internet):* `a.ntp.br`, `b.ntp.br`, `pool.ntp.org`.
    *   *NTP Interno (para redes locais isoladas/offline):* Endereço IP do servidor NTP local disponibilizado pela equipe de TI do cliente.

---

## 3. Requisitos de Rede e Portas (Firewall)

Os containers Docker rodam em uma rede isolada, mas expõem portas específicas para o host. A equipe de rede/firewall do cliente deve liberar o tráfego nas seguintes portas:

| Serviço | Porta Padrão | Protocolo | Origem | Destino | Descrição |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Mosquitto** | `1883` | TCP | Sensores / Coletores | Servidor | Comunicação MQTT (sem criptografia) |
| **Mosquitto (TLS)** | `8883` | TCP | Sensores / Coletores | Servidor | Comunicação MQTT Segura (criptografada) |
| **Grafana** | `3000` | TCP | Computadores dos Usuários | Servidor | Acesso à interface web de dashboards |
| **InfluxDB** | `8086` | TCP | Telegraf / Integrações externas | Servidor | API do Banco de Dados (opcional para consumo externo) |

---

## 4. Estimativa de Crescimento de Disco (Armazenamento)

O InfluxDB utiliza algoritmos avançados de compactação de dados. Uma estimativa média de consumo para **20 sensores** enviando métricas a cada 10 segundos é:

*   **Pontos de dados gerados por ano:** ~63 milhões de escritas.
*   **Espaço consumido pelo banco de dados:** Menos de **1.5 GB a 2 GB por ano**.
*   **Recomendação de política:** Uma partição de **30 GB** dedicada ao diretório de dados do Docker garante anos de funcionamento sem necessidade de expansão de disco.

---

## 5. Dependência de Internet (Conectividade)

A stack de monitoramento é projetada para rodar de forma **100% offline (on-premise / rede local isolada)**. 

*   **Download Inicial:** É necessário acesso à internet apenas uma única vez para baixar as imagens Docker (`docker compose pull`) e sincronizar as dependências no momento da instalação.
*   **Funcionamento em Produção:** Totalmente local. O servidor não envia nenhum dado para fora da rede interna do cliente, a menos que seja configurada alguma integração de terceiros (como envio de e-mails de alerta ou notificações via Teams/Telegram pelo Grafana).

---

## 6. Persistência e Política de Backup

Para garantir que os dados de configuração e histórico de métricas não sejam perdidos em caso de falha no host ou reinicialização do container, todas as pastas de dados importantes são mapeadas para diretórios locais no servidor (volumes do host).

Os dados críticos para backup estão localizados na raiz da pasta do projeto:
*   `./grafana/data` - Contém as contas de usuários, dashboards e configurações do Grafana.
*   `./influxdb/data` - Contém todo o histórico de métricas salvas.
*   `./mosquitto/data` - Arquivos de persistência de fila do broker MQTT.
*   `./configs` - Configurações de autenticação e parâmetros do Telegraf/Mosquitto.

> [!TIP]
> **Estratégia de Backup:** A TI do cliente pode fazer backup diário de toda a pasta raiz do projeto no servidor host, ou usar ferramentas nativas como `influx backup` de forma automatizada via cron.
