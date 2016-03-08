net = require "net"
tls = require "tls"
Session = require "./tcp_session"

class Client extends Session
  requests = {}
  lastID = 0
  connected = false
  connecting = false

  constructor:(port, host, secure)->
    super()
    @on "error", ()-> connected = false
    @timeout = 60000
    if host? and port? then @connect port, host, secure
    @on "message", (message)=>
      if !message.id?
        @emit message.method, message.result
      else
        request = requests[message.id]
        if request?
          request.replies++
          request.time = Date.now()
          if message.error?
            request.callback message.error, message.result
            @cancelRequest request.id
          else
            request.callback null, message.result
    setInterval ()=>
      now = Date.now()
      for _,request of requests
        if (now - request.time) > request.timeout
          if !request.replies then request.callback "timeout"
          @cancelRequest request.id
    ,@timeout

  connect:(@port, @host, @secure, callback)->
    connecting = true
    transport = if @secure? then tls else net
    @init transport.connect @port, @host, (err)=>
      connecting = false
      @emit "connect-result", err
      callback? err

    @socket.on "connect", ()=>
      if !connected
        connected = true
        @emit "connect"
    @socket.on "close", ()-> connected = false


  reconnect:(callback)->
    @socket.destroy()
    @connect @port, @host, @secure, callback

  onceReady: (callback)->
    if connected then callback() else @once "connect", callback

  onceConnected: (callback)->
    if connected then callback() else @once "connect-result", callback

  cancelRequest:(id)->
    delete requests[id]

  call:(method, params, callback, timeout)->
    if connected
      @_call method, params, callback, timeout
    else
      if connecting
        @onceConnected (err)=> if err? then callback err else @_call method, params, callback, timeout
      else
        @reconnect (err)=> if err? then callback err else @_call method, params, callback, timeout

  _call:(method, params, callback, timeout)->
    id = ++lastID
    @sendMessage id, method, params, (err)=>
      if err
        callback err
      else
        requests[id] = {id:id, time:(new Date).getTime(), callback: callback, replies: 0, timeout:timeout||@timeout}




module.exports = Client
