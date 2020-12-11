output "function_arn" {
  value = aws_lambda_function.ses_redirecter.arn
}

output "instructions" {
  value = data.template_file.instructions.rendered
}