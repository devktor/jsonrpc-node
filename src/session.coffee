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


  send:(object, callback)->
    @socket.write @format(object), @encoding, callback


  format: (msg)->
    "#{JSON.stringify msg}\n"


  close:()-> @socket.close()




module.exports = Session