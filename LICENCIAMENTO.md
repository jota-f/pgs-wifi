# Licenciamento de Software (PGS Plus)

Este documento detalha o licenciamento da stack de monitoramento do **TBi PGS Plus** para responder a auditorias e validações das equipes de TI e Jurídico de clientes/parceiros.

---

## 1. Licenciamento dos Softwares (Open Source vs. Comercial)

Toda a stack padrão fornecida neste repositório é composta por softwares consagrados no mercado e configurada para utilizar **versões de código aberto (Open Source / OSS)**, permitindo o uso comercial sem custo de licenciamento ou pagamento de royalties.

| Serviço | Função | Licença Utilizada | Termos de Uso / Observações |
| :--- | :--- | :--- | :--- |
| **Eclipse Mosquitto** | MQTT Broker (mensageria) | [EPL-2.0](https://www.eclipse.org/legal/epl-2.0/) / [EDL-1.0](https://www.eclipse.org/org/documents/edl-1.0.php) | **Livre para uso comercial.** Código aberto e extremamente leve. |
| **Telegraf** | Coletor e encaminhador de métricas | [MIT](https://github.com/influxdata/telegraf/blob/master/LICENSE) | **Livre para uso comercial.** Sem royalties, sem restrições de distribuição. |
| **InfluxDB** | Banco de dados de séries temporais (TSDB) | [MIT](https://github.com/influxdata/influxdb/blob/master/LICENSE) (Versão OSS) | **Livre para uso comercial.** <br> *Nota:* Apenas as edições *Enterprise* ou *InfluxDB 3 Clustered* possuem custos de licença. A versão utilizada na stack (OSS v2) é gratuita. |
| **Grafana** | Visualizador de métricas e alertas | [AGPLv3](https://github.com/grafana/grafana/blob/main/LICENSE) (Grafana OSS) | **Livre para uso comercial.** <br> *Nota:* O Grafana OSS (Open Source Software) atende a todos os requisitos de dashboards e alertas da solução sem necessidade de licença comercial Enterprise. |

---

## 2. Termos de Distribuição e Modificação dos Softwares OSS
As licenças aplicadas aos softwares de terceiros (Mosquitto, Telegraf, InfluxDB, Grafana) descritos na seção anterior permitem aos clientes/empresas:
*   **Uso interno** sem custos de licenciamento ou pagamento de royalties.
*   **Execução em servidores locais (on-premise) ou nuvem** de forma independente.
*   **Modificações e customizações** nos arquivos de configuração do banco e dos coletores.

---

## 3. Propriedade Intelectual e Restrição Comercial do Repositório (PGS Plus)

Apesar dos serviços subjacentes utilizarem licenças de código aberto, os arquivos de integração, orquestração e configurações customizadas criados especificamente para a solução PGS Plus contidos neste repositório estão protegidos sob direitos de propriedade intelectual da desenvolvedora da solução.

### Termos de Uso do Repositório:
*   **Permitido (Uso Interno)**: É concedido às empresas parceiras e clientes finais o direito de clonar, implantar e utilizar as configurações deste repositório para o monitoramento interno de seus próprios sensores PGS Plus.
*   **Proibido (Venda e Redistribuição comercial)**: É expressamente **proibida a venda, sublicenciamento, redistribuição comercial, empacotamento ou revenda** deste repositório, de suas configurações compiladas, scripts de automação ou dashboards personalizados para terceiros sem autorização prévia por escrito do detentor dos direitos autorais.
*   **Controle de Revenda**: Apenas parceiros e distribuidores oficialmente autorizados estão licenciados a comercializar soluções baseadas nas configurações e orquestrações fornecidas neste repositório.
