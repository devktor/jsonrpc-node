net = require "net"
Session = require "./session"

class Client extends Session
  requests = {}
  lastID = 0
  connected = false

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
    console.log "trying to connect ", arguments
    if !callback? then callback = (err)-> console.log "#{if err? then 'failed to connect' else 'connected'} #{@ip}:#{@port}"
    console.log "callback = ",callback
    @init net.connect(@port, @host, callback)
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

  cancelRequest:(id)->
    delete requests[id]

  call:(method, params, callback, timeout)->
    if connected
      @_call method, params, callback, timeout
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