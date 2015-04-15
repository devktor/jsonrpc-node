
exportData =
  TCP:
    Client: require "./tcp_client"
    Server: require "./tcp_server"
  HTTP:
    Client: require "./http_client"
    Server: require "./http_server"

exportData.Client = exportData.TCP.Client
exportData.Server = exportData.TCP.Server

module.exports = exportData



