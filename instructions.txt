...
## In Amazon SES, verify the domain that you want to use to receive incoming email.
For more information, see https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-domain-procedure.html

If this does not already exist in Route53, add the following MX record to the DNS configuration for your domain:

10 inbound-smtp.${aws_region}.amazonaws.com

## Create a Receipt Rule Set
In the Amazon SES console, make sure there is an active receipt rule set.
If needed, create one.

For more information, see https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-receipt-rule-set.html

In the active Receipt Rule Set, add a Receipt Rule.
In the Receipt Rule, add an S3 Action.
Set up the S3 Action to send your email to
the S3 bucket: ${s3_email_bucket}
using the Object key prefix: ${s3_email_prefix}.

Add the Lambda action to the Receipt Rule.
Configure the Receipt Rule to invoke the Lambda function: ${function_name}.
(Use Invocation Type: Event)