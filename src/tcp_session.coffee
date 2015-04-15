{EventEmitter} = require "events"
readline = require "readline"

class Session extends EventEmitter

  constructor:(socket)->
    if socket? then @init socket

  clear:()->
    if @socket?
      @stream.close()
      @socket.destroy()
      delete @stream
      delete @socket

  init:(socket)->
    @clear()

    @socket = socket
    @encoding = "utf8"
    @delimiter = "\n"
    @socket.setEncoding @encoding
    @socket.on "error", (msg)=> @emit "error", msg
    @stream = readline.createInterface @socket, @socket
    @stream.on "line",(data)=>
      try
        msg = JSON.parse data
        @emit "message", msg
      catch e
        @emit "error", "#{e}"


  sendData:(object, callback)->
    @socket.write @format(object), @encoding, callback

  sendNotification:(method, params, callback)-> @sendData id:null, method:method, params:params, callback
  sendError:(id, method, message, callback)-> @sendData id:id, method:method, error:message, callback
  sendMessage:(id, method, params, callback)-> @sendData id:id, method:method, params:params, callback

  format: (msg)->
    "#{JSON.stringify msg}\n"


  close:()-> @socket.close()




module.exports = Session