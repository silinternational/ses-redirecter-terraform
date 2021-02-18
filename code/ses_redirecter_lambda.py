# Copyright 2010-2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# This file is licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License. A copy of the
# License is located at
#
# http://aws.amazon.com/apache2.0/
#
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

import os
import boto3
import email
import re
from botocore.exceptions import ClientError
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication

region = os.environ['Region']

def get_text_email_info(mailobject):
    content_type = mailobject.get_content_type()
    content_type_parts = content_type.split("/")
    sub_type = content_type_parts[-1]
    if not sub_type:
        sub_type = "plain"
        
    charset = mailobject.get_content_charset()
    if not charset:
        charset = 'utf-8'

    body_text = mailobject.get_payload(decode=True)
    return sub_type, charset, body_text

def get_attachment_info(att_index, mime_part):
    filename = mime_part.get_filename()
    if not filename:
        filename = "attachment_" + str(att_index)
                

    file_contents = mime_part.get_payload(decode=True)
                
    next = MIMEApplication(file_contents, filename) 
    next.add_header("Content-Disposition", 'attachment', filename=filename)
    next.add_header('Content-Transfer-Encoding', 'base64')
    next.set_payload(file_contents)  
    return next

def get_message_from_s3(message_id):

    incoming_email_bucket = os.environ['MailS3Bucket']
    incoming_email_prefix = os.environ['MailS3Prefix']

    if incoming_email_prefix:
        object_path = (incoming_email_prefix + "/" + message_id)
    else:
        object_path = message_id

    object_http_path = (f"http://s3.console.aws.amazon.com/s3/object/{incoming_email_bucket}/{object_path}?region={region}")

    # Create a new S3 client.
    client_s3 = boto3.client("s3")

    # Get the email object from the S3 bucket.
    object_s3 = client_s3.get_object(Bucket=incoming_email_bucket,
        Key=object_path)
    # Read the content of the message.
    file = object_s3['Body'].read()

    file_dict = {
        "file": file,
        "path": object_http_path
    }

    return file_dict

def create_message(file_dict):

    sender = os.environ['MailSender']
    recipient = os.environ['MailRecipient']

    separator = ";"

    # Parse the email body.
    mailobject = email.message_from_string(file_dict['file'].decode('utf-8'))
    
    reply_to = mailobject.get('from')
    
    # Create a new subject line.
    subject_original = mailobject['Subject']
    
    content_type = mailobject.get_content_type()
    content_type_parts = content_type.split("/")
    
    sub_type = "plain"
    charset = "ascii"
    body_text = "Oops. Something went wrong getting the original message."
    
    # Create a MIME container.
    msg = MIMEMultipart()    
    
    if content_type_parts[0] == "text":
        sub_type, charset, body_text = get_text_email_info(mailobject)        
    elif content_type_parts[0] == "multipart":   #  /mixed":
        mime_parts = mailobject.get_payload()

        i = 1
        for part in mime_parts:
            part_cnt_disp = part.get_content_disposition()
            if part_cnt_disp is None:
                sub_type, charset, body_text = get_text_email_info(part)

            elif part_cnt_disp == "attachment":
                # Attach the file object to the message.
                next = get_attachment_info(i, part)
                
                msg.attach(next)
                i += 1


    # Create a MIME text part.
    text_part = MIMEText(body_text, _subtype=sub_type, _charset=charset)
    # Attach the text part to the MIME message.
    msg.attach(text_part)

    # Add subject, from and to lines.
    msg['Subject'] = subject_original
    msg['From'] = sender
    msg['To'] = recipient
    if reply_to:
        msg['Reply-To'] = reply_to


    message = {
        "Source": sender,
        "Destinations": recipient,
        "Data": msg.as_string()
    }

    return message

def send_email(message):
    aws_region = os.environ['Region']

# Create a new SES client.
    client_ses = boto3.client('ses', region)

    # Send the email.
    try:
        #Provide the contents of the email.
        response = client_ses.send_raw_email(
            Source=message['Source'],
            Destinations=[
                message['Destinations']
            ],
            RawMessage={
                'Data':message['Data']
            }
        )

    # Display an error if something goes wrong.
    except ClientError as e:
        output = e.response['Error']['Message']
    else:
        output = "Email sent! Message ID: " + response['MessageId']

    return output

def lambda_handler(event, context):
    # Get the unique ID of the message. This corresponds to the name of the file
    # in S3.
    
    print(f"event Records 0  {event['Records'][0]}")
    
    message_id = event['Records'][0]['ses']['mail']['messageId']
    print(f"Received message ID {message_id}")

    # Retrieve the file from the S3 bucket.
    file_dict = get_message_from_s3(message_id)

    # Create the message.
    message = create_message(file_dict)

    # Send the email and print the result.
    result = send_email(message)
    print(result)
