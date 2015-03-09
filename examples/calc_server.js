RPCServer = require("jsonrpc-node").Server;


function sum(reply, a, b, c){
    reply.error(a+b+c);
}

function multiply(reply, a, b, c){
    reply(a*b*c);
}

var server = new RPCServer({sum:sum})

server.register("multiply", multiply);

port = process.env.PORT || 3001

server.listen(port, function(){
  console.log('Server listening on port '+port);
})



