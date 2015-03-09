Client = require("../").Client

var client = new Client();

client.connect(process.env.PORT || 3001, "localhost");

client.call("sum", [1,2,3], function(err, result){
    console.log("err=",err," result=",result);
});

