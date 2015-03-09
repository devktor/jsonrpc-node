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
var server = new RPCServer({echo:function(args){return {result:args};});
```
or without arguments
```javascript
var server = new RPCServer();
```

Register some methods
```javascript
server.register("ping", function(args){ return "pong";})
```

or bulk register
```javascript
server.register({ping:function(args){return "pong";}, time:function(args){return Date.now();}}
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
