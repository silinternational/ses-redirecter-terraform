
## In Amazon SES create a Receipt Rule Set
In the Amazon SES console, make sure there is an active receipt rule set.
If needed, create one.

For more information, see https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-receipt-rule-set.html

- In the active Receipt Rule Set, add a Receipt Rule.
- In the Receipt Rule, add an S3 Action.
- Set up the S3 Action to send your email to the S3 bucket: ${s3_email_bucket} using the Object key prefix: ${s3_email_prefix}.
- Add the Lambda action to the Receipt Rule.
- Configure the Receipt Rule to invoke the Lambda function: ${function_name}.
(Use Invocation Type: Event)