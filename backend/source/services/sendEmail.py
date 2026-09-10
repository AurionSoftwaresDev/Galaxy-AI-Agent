import resend
from source.config.configs import getResendFromAgentEmail, getResendAPIKey
from source.utils.logger import logger

def sendEmail(to : str, subject : str, body : str) -> list[dict[str, str | None]]:

    logger.info(f'Galaxy AI Agent Sending Email To: "{to}"')

    from_email = getResendFromAgentEmail()

    try:
        resend.api_key = getResendAPIKey()

        mail_content = {
            "from": f"Galaxy AI Agent <{from_email}>",
            "to": to,
            "subject": subject,
            "html": body,
        }

        resend.Emails.send(params=mail_content)

        logger.info(f'Email Sent Successfully To: "{to}"')

        return [
            {
                "status": "sent",
                "subject": subject,
                "from": from_email,
                "to": to,
                "body": body,
            }
        ]

    except Exception as exception:

        logger.exception(
            f'AI Agent Failed To Send Email: To: "{to}" '
            f"Exception: {exception}"
        )

        return [
            {
                "status": "failed",
                "subject": subject,
                "from": from_email,
                "to": to,
                "body": body,
            }
        ]

