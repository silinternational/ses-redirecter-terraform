output "function_arn" {
  value = aws_lambda_function.ses_redirecter.arn
}

output "record_mx_record" {
  value = join(" ", [aws_route53_record.mx.name, aws_route53_record.mx.records[0]])
}


output "instructions" {
  value = data.template_file.instructions.rendered
}