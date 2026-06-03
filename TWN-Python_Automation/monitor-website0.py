import requests

response = requests.get('http://74.207.228.174:8080/')
if response.status_code == 200:
    print('Application is running successfully!')
else:
    print('Applicatiion is Down. Please Fix it!!')
    # send email to me!!

