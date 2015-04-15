net = require "net"
Session = require "./tcp_session"

class Client extends Session
  requests = {}
  lastID = 0
  connected = false
  connecting = false

  constructor:(port, host)->
    super()
    @on "error", ()-> connected = false
    @timeout = 60000
    if host? and port? then @connect port, host
    @on "message", (message)=>
      if !message.id?
        @emit message.method, message.params
      else
        request = requests[message.id]
        if request?
          request.replies++
          request.time = Date.now()
          if message.error?
            request.callback message.error, message.params
            @cancelRequest request.id
          else
            request.callback null, message.params
    setInterval ()=>
      now = Date.now()
      for _,request of requests
        if (now - request.time) > request.timeout
          if !request.replies then request.callback "timeout"
          @cancelRequest request.id
    ,@timeout

  connect:(@port, @host, callback)->
    connecting = true
    @init net.connect @port, @host, (err)=>
      console.log "#{if err? then 'failed to connect' else 'connected'} #{@host}:#{@port}"
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
    @connect @port, @host, callback

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
        @onceConnected if err? then callback err else @_call method, params, callback, timeout
      else
        @reconnect (err)=> if err? then callback err else @_call method, params, callback, timeout

  _call:(method, params, callback, timeout)->
    id = ++lastID
    @sendMessage id, method, params, (err)=>
      if err
        callback err
      else
        requests[id] = {id:id, time:Date.now(), callback: callback, replies: 0, timeout:timeout||@timeout}




module.exports = Client