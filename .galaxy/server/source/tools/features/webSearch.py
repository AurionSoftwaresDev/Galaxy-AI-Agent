from gnews import GNews
from langchain.tools import tool
from source.utils.logger import logger

def webSearch(query : str, language : str, country : str, max_results : int = 10) -> str:

    logger.info("AI Agent Called fetching_news Tool...")
    
    logger.info("AI Agent Information Fetching From Internet Using GNews")
    
    latestNews = GNews(
        language=language,
        country=country,
        max_results=max_results
    )
    
    articles = latestNews.get_news(query)
    
    if not articles:
        
        return "Details Not Found"
    
    results = []
    
    for article in articles:
        
        results.append({
            "title": article.get("title"),
            "description": article.get("description"),
            "published": article.get("published date"),
            "publisher": article.get("publisher"),
            "url": article.get("url"),
        })

    logger.info("AI Agent Information Feteching Completed")

    return str(results)
