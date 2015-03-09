RPCServer = require("../").Server;


function sum(args, reply){
    var result = 0;
    for(var i in args){
        result+=args[i];
    }
    reply.error(result);
}

function multiply(args, reply){
    var result = 0;
    for(var i in args){
        result*=args[i];
    }
    reply(result);
}

var server = new RPCServer({sum:sum})

server.register("multiply", multiply);

port = process.env.PORT || 3001

server.listen(port, function(){
  console.log('Server listening on port '+port);
})



