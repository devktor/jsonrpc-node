net = require "net"
Session = require "./session"

class Client extends Session
  constructor:(host)->
    @requests = {}
    @lastID = 0
    @timeout = 60000
    if host? then @connect host

  connect:(@host)->
    @init net.connect.apply @, arguments
    @socket.on "connection", ()=> @emit "connection"
    @on "message", (message)=>
      request = @requests[message.id]
      if request?
        request.replies++
        request.time = Date.now()
        if message.error?
          request.callback message.error, message
          delete @requests[request.id]
        else
          request.callback null, message
    setInterval ()=>
      now = Date.now()
      for _,request of @requests
        if (now - request.time) > @timeout
          if !request.replies then request.callback "timeout"
          delete @requests[request.id]
    ,@timeout

  call:(method, params, callback)->
    id = ++@lastID
    @sendMessage id, method, params, (err)=>
      if err
        callback err
      else
        @requests[id] = {id:id, time:Date.now(), callback: callback, replies: 0}




module.exports = Client