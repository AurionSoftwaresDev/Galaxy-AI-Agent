from pydantic import BaseModel, Field

class WebSearchSchema(BaseModel):
    
    query : str = Field(description = "Fetch Latest News And Specific Date News")
    language : str = Field(default = "en", description = "Language For Searching")
    country : str = Field(default = "IN", description = "Country For Searching And Value In Short Like India -> IN And Default Is IN")
    max_results : int = Field(default = 10, ge = 1, le = 20, description = "Limit Of Searching")