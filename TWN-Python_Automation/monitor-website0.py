import smtplib
import requests
import os

EMAIL_ADDRESS = os.environ.get('EMAIL_ADDRESS')
EMAIL_PASSWORD = os.environ.get('EMAIL_PASSWORD')

def send_notification(email_msg):
    with smtplib.SMTP('smtp.gmail.com', 587) as smtp:
        smtp.ehlo()
        smtp.starttls()
        smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        message = f"Subject: SITE DOWN\n{email_msg}"
        smtp.sendmail(EMAIL_ADDRESS, EMAIL_ADDRESS, message)


try:
    response = requests.get('http://74.207.228.174:8080/')
    if response.status_code == 200:
        print('Application is running successfully!')
    else:
        print('Application is Down. Please Fix it!!')
        msg = f"Application returned {response.status_code}"
        send_notification(msg)
except Exception as ex:
    print(f'Connection error happened: {ex}')
    msg = f"Application not accessible at all!!"
    send_notification(msg)


