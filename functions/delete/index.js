console.log('starting function')
exports.handle = function(e, ctx, cb) {
  console.log('processing event: %j', e)

  var AWS = require('aws-sdk');
  AWS.config.update({endpoint: 'http://192.168.30.96:8001', region: 'localhost'});
  var doc = require('dynamodb-doc');
  var dynamo = new doc.DynamoDB();

  var pfunc = function(err, data) {
      if (err) {
          console.log(err, err.stack);
      }
      else {
          console.log(data);
      }
  }
  console.dir(e);

  // var deleteParams = {
  //   TableName: "heroes",
  //   Key: {
  //     id:"4"
  //   }
  // }

  // function deleteItem(params){
  //   dynamo.deleteItem(params,pfunc);
  // }

  cb(null, { hello: 'world' })
}
