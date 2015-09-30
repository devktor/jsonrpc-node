##JsonRPC-Node
Multi transport JSON-RPC client/server with SSL support for node.js

Can be used as stand alone server or as net.Server/express middleware

###installation
```bash
npm install jsonrpc-node
```

###server

Include library
```javascript
Server = require("jsonrpc-node").TCP.Server;
```
or over http
```javascript
Server = require("jsonrpc-node").HTTP.Server;
```

Create server object
```javascript
var server = new Server({echo:function(args, reply){return reply(args);}});
```
or without arguments
```javascript
var server = new Server();
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
server.register({ping:function(args, reply){reply("pong");}, time:function(args, reply){return reply.error("some error");}});
```


Start listening
```javascript
server.listen(3001, "localhost")
```
or use SSL connection
```javascript
server.listenSSL(3001, "localhost","key.pem","cert.pem");
```

or can be used as middleware,

tcp server for net.Server

```javascript
net.createServer(server)
```

http server for express

```javascript
var app = express();
app.use("/api", server);
```


###client

Include library
```javascript
Client = require("jsonrpc-node").TCP.Client;
```
or
```javascript
Client = require("jsonrpc-node").HTTP.Client;
```

Create client object
```javascript
client = new Client(3001, "localhost");
```


Execute remote methods
```javascript
client.call("multiply", [1,2,4], function(err, result){})
```
