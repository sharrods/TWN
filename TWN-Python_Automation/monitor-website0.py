import smtplib
import requests
import os
import paramiko
import linode_api4


EMAIL_ADDRESS = os.environ.get('EMAIL_ADDRESS')
EMAIL_PASSWORD = os.environ.get('EMAIL_PASSWORD')
LINODE_TOKEN = os.environ.get('LINODE_TOKEN')

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
    #if False:
        print('Application is running successfully!')
    else:
        print('Application is Down. Please Fix it!!')
        msg = f"Application returned {response.status_code}"
        send_notification(msg)

        # Restart the application†
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(hostname='74.207.228.174', username='root', key_filename='/Users/sharrods/.ssh/id_ed25519')
        stdin, stdout, stderr = ssh.exec_command('docker start 2ff4e1af46f3')
        print(stdout.readlines())
        ssh.close()
        print('Application restarted')

except Exception as ex:
    print(f'Connection error happened: {ex}')
    msg = f"Application not accessible at all!!"
    send_notification(msg)


    # restart linode server
    client = linode_api4.LinodeClient(LINODE_TOKEN)
    nginx_server = client.load(linode_api4.Instance, 98587330 )
    nginx_server.reboot()

    # restart application