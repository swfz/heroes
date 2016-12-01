console.log('starting function')
exports.handle = function(e, ctx, cb) {
  console.log('processing event: %j', e)

  var AWS = require('aws-sdk');
  AWS.config.update({endpoint: 'dynamodb.ap-northeast-1.amazonaws.com', region: 'ap-northeast-1'});
  var doc = require('dynamodb-doc');
  var dynamo = new doc.DynamoDB();

  var pfunc = function(err, data) {
    if (err) {
      console.log(err, err.stack);
    }
    else {
      console.log(data);
      var res = {
        "statusCode": 201,
        "headers": {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "PUT,POST,HEAD,OPTIONS"
        },
        "body": JSON.stringify(data)
      };
      cb(null, res);
    }
  }
//  console.dir(e);

  function putItem(hero){
    var params = {
      TableName: "SampleDynamoHeroes",
      Item: hero
    };

    dynamo.putItem(params,pfunc);
  }

  console.dir(e["body"])
  putItem(JSON.parse(e["body"]));
}
