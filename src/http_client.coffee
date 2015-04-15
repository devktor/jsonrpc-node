BasicAuth = require "./http_client_basic_auth"

class Client
  constructor:(url)->
    @transport = if url.protocol? and url.protocol == "https" then require "https" else require "http"
    @host = url.host
    @port = url.port
    @path = url.path

  setAuth:(@auth)->

  setBasicAuth: (username, password)->
    @setAuth new BasicAuth username, password

  call: (method, params, callback)->
    request = {method: method, params: params}
    options =
      host: @host
      port: @port
      method: "post"
      path: @path
      headers:
        Host: @host

    if @auth?
      @auth.sign options, request

    query = JSON.stringify request
    options.headers['Content-Length'] = query.length
    options.headers["Content-Type"]  = "application/json"

    #    options.rejectUnauthorized = false

    request = @transport.request options

    request.on "error", (err)->
      callback err

    request.on "response", (response)->
      buffer = ''
      response.on 'data', (chunk)->
        buffer += chunk
      response.on 'end', ()->
        err = msg = null
        if response.statusCode == 200
          try
            json = JSON.parse buffer
            if json.error? then err = json.err
            if json.result then msg = json.result
          catch e
            err = e
        else
          err = "Server replied with : "+response.statusCode
        callback err, msg

    request.end query


module.exports = Client