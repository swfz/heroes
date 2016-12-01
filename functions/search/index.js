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
        "statusCode": 200,
        "headers": {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET,POST,HEAD,OPTIONS"
        },
        "body": JSON.stringify(data["Items"])
      };
      cb(null, res);
    }
  }
  console.dir(e);

  var scanParams = {
    TableName: "SampleDynamoHeroes",
    Select: "ALL_ATTRIBUTES"
  };

  function scanItems(params){
    dynamo.scan(params,pfunc);
  }

  scanItems(scanParams);
}
