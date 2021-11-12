locals {
  lambda-zip-location = "outputs/lambdacode_stop_ec2.zip"
  lambda-zip-location2 = "outputs/lambdacode_start_ec2.zip"
}


data "archive_file" "init" {
  type        = "zip"
  source_file = "lambdacode_stop_ec2.py"
  output_path = local.lambda-zip-location
}

data "archive_file" "init2" {
  type        = "zip"
  source_file = "lambdacode_start_ec2.py"
  output_path = local.lambda-zip-location2
}

resource "aws_lambda_function" "test_lambda-stop-ec2-terra" {
  filename      = local.lambda-zip-location
  function_name = "lambdacode_stop_ec2"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambdacode_stop_ec2.lambda_handler"
  source_code_hash = filebase64sha256(local.lambda-zip-location)

 
 

  runtime = "python3.7"

  
}


resource "aws_lambda_function" "test_lambda-start-ec2-terra" {
  filename      = local.lambda-zip-location2
  function_name = "lambdacode_start_ec2"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambdacode_start_ec2.lambda_handler"
  source_code_hash = filebase64sha256(local.lambda-zip-location2)

  runtime = "python3.7"

  
}

resource "aws_cloudwatch_event_rule" "stopping-ec2" {
  name                = "stopping-ec2"
  schedule_expression = "cron(37 7 * * ? *)"

}

resource "aws_cloudwatch_event_target" "stopping-ec2-target" {
  rule      = aws_cloudwatch_event_rule.stopping-ec2.name
  target_id = aws_lambda_function.test_lambda-stop-ec2-terra.id
  arn       = aws_lambda_function.test_lambda-stop-ec2-terra.arn
  
}

resource "aws_cloudwatch_event_rule" "starting-ec2" {
  name                = "starting-ec2"
  schedule_expression = "cron(35 7 * * ? *)"

}

resource "aws_cloudwatch_event_target" "starting-ec2-target" {
  rule      = aws_cloudwatch_event_rule.starting-ec2.name
  target_id = aws_lambda_function.test_lambda-start-ec2-terra.id
  arn       = aws_lambda_function.test_lambda-start-ec2-terra.arn
  
}



resource "aws_lambda_permission" "allow_lambda1" {
  statement_id = "AllowExecutionFromLambda1"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.test_lambda-stop-ec2-terra.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.stopping-ec2.arn}"
}




resource "aws_lambda_permission" "allow_lambda2" {
  statement_id = "AllowExecutionFromLambda2"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.test_lambda-start-ec2-terra.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.starting-ec2.arn}"
}


















# resource "aws_lambda_permission" "allow_bucket" {
#   statement_id  = "AllowExecutionFromS3Bucket"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.test_lambda_1.arn
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.bucket.arn
# }


# resource "aws_s3_bucket_notification" "bucket_notification" {
#   bucket = aws_s3_bucket.bucket.id

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.test_lambda_1.arn
#     events              = ["s3:ObjectCreated:*"]
#  #   filter_prefix       = "AWSLogs/"
#   #  filter_suffix       = ".log"
#   }

#   depends_on = [aws_lambda_permission.allow_bucket]
# }