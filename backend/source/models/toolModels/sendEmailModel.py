from pydantic import BaseModel, Field

class sendEmailModel(BaseModel):
    
    to : str = Field(description = "To Email Address")
    subject : str
    html : str = Field(description = "Email Body In HTML Form")