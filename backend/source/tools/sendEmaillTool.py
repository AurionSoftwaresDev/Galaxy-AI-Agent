from langchain_core.tools import StructuredTool
from source.services.sendEmail import sendEmail
from source.models.sendEmailModel import sendEmailModel

sendEmailTool : StructuredTool = StructuredTool.from_function(
    func = sendEmail,
    name = "send_email",
    description = """
        Send an email to a specified recipient.

        Use this tool when th euser explicitly asks you to send, compose and send,
        or deliver an email. must be provide. The `to` argument must contains the recipient's email address.
    """,
    args_schema = sendEmailModel
)