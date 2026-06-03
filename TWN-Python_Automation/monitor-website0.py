import smtplib
import requests
import os

EMAIL_ADDRESS = os.environ.get('EMAIL_ADDRESS')
EMAIL_PASSWORD = os.environ.get('EMAIL_PASSWORD')


response = requests.get('http://74.207.228.174:8080/')
if False:
    print('Application is running successfully!')
else:
    print('Application is Down. Please Fix it!!')
    # send email to me
    with smtplib.SMTP('smtp.gmail.com', 587) as smtp:
        smtp.ehlo()
        smtp.starttls()
        smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        msg = "Subject: SITE DOWN\nFix the issue!"
        smtp.sendmail(EMAIL_ADDRESS, EMAIL_ADDRESS, msg )


