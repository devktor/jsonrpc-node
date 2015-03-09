##JSONRPC-Node
JSON RPC client/server over TCP for node.js


###installation
```bash
npm install jsonrpc-node
```

###server

Include library
```javascript
RPCServer = require("jsonrpc-node").Server;
```
Create server object
```javascript
var server = new RPCServer({echo:function(args, reply){return reply(args);});
```
or without arguments
```javascript
var server = new RPCServer();
```

Register some methods
```javascript
server.register("ping", function(args, reply){
    reply("pong");
    reply.notify("pong2"); //data can be streamed
});

```

or bulk register
```javascript
server.register({ping:function(args, reply){reply("pong");}, time:function(args, reply){return reply.error("some error");}}
```


Start listening
```javascript
server.listen(3001, "localhost")
```


###client

Include library
```javascript
Client = require("jsonrpc-node").Client;
```

Create client object
```javascript
client = new Client();
```

Connect to server
```
client.connect(3001, "localhost")
```

Execute remote methods
```javascript
client2.call("multiply", [1,2,4], function(err, result){})
```
