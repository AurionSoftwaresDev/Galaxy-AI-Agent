import smtplib
import json
from source.config.configs import(
     getSMTPPORT, 
     getSMTPSenderEmail,
     getSMTPSenderPassword,
     getSMTPServerHost

)
from email.message import EmailMessage
from source.utils.logger import logger

def sendEmail(to : str, subject : str, html : str) -> str:

    logger.info("AI Agent Called send_email Tool...")

    FROM_EMAIL : str = str(getSMTPSenderEmail())

    SMTP_PORT : str = str(getSMTPPORT())
    SMTP_SERVER_HOST : str = str(getSMTPServerHost())
    SMTP_SENDER_PASSWORD : str = str(getSMTPSenderPassword())

    logger.info(f'Galaxy AI Agent Sending Email To: "{to}"')

    try:

        mail = EmailMessage()

        mail["Subject"] = subject
        mail["To"] = to
        mail["From"] = FROM_EMAIL

        mail.set_content("This Email Contains HTML Content...")

        mail.add_alternative(html, subtype="html")

        logger.info("Connecting To SMTP Server For Sending Email...")

        server = smtplib.SMTP(host = SMTP_SERVER_HOST, port = SMTP_PORT)

        server.ehlo() 
        
        server.starttls()

        server.ehlo()  

        logger.info("AI Agent Logging In To User Account To Send Email...")

        server.login(user = FROM_EMAIL, password = SMTP_SENDER_PASSWORD)
        
        server.send_message(mail)
        
        logger.info(f'Galaxy AI Agent Sended Email Successfully To: "{to}"')

        return json.dumps([
            {
                "status": "Sended",
                "subject": subject,
                "from": FROM_EMAIL,
                "to": to,
                "body": html
            }
        ], indent = 4)

    except Exception as exception:

        logger.exception(f"AI Agent Failed To Send Email: To : \" { to } \" Exception: { exception } ")

        return json.dumps([
            {
                "status": "Failed",
                "subject": subject,
                "from": FROM_EMAIL,
                "to": to,
                "body": html,
            }
        ], indent = 4)