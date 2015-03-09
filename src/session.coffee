{EventEmitter} = require "events"

class Session extends EventEmitter

  constructor:(socket)->
    if socket? then @init socket

  init:(@socket)->
    @encoding = "utf8"
    @delimiter = "\n"
    @socket.setEncoding @encoding
    @socket.on "error", (msg)=> @emit "error", msg
    @socket.on "data", (data)=>
      if data.slice(-1) != @delimiter
        @emit "error", "invalid message"
      else
        try
          msg = JSON.parse data
          @emit "message", msg
        catch e
          @emit "error", "#{e}"

  sendError:(id, method, msg, callback)->
    msg =
      id: id
      method: method
      error: msg
    @socket.write @format(msg), @encoding, callback


  sendMessage:(id, method, params, callback)->
    msg =
      id: id,
      method: method,
      params: params
    @socket.write @format(msg), @encoding, callback


  sendNotification:(method, params, callback)->
    @sendMessage null, method, params, callback


  format: (msg)->
    "#{JSON.stringify msg}\n"


  close:()-> @socket.close()




module.exports = Session