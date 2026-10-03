import re
from pathlib import Path
from difflib import SequenceMatcher

def normalizeName(name : str) -> str:
    """
        Normalizes an application name so different naming styles
        can be compared.

        Examples:
            "Visual Studio Code" -> "visual studio code"
            "IntelliJ-IDEA"      -> "intellij idea"
            "Chrome.app"         -> "chrome"
    """

    name = Path(name).stem

    name = re.sub(
        r"[^a-zA-Z0-9]+",
        " ",
        name
    )

    return " ".join(
        name.lower().split()
    )


def matchScore(requestedName: str, candidateName : str) -> float:
    """
        Returns a similarity score between two application names.

        Score:
            1.0  = exact match
            0.0  = no meaningful match
    """

    requested = normalizeName(name = requestedName)

    candidate = normalizeName(name = candidateName)

    if not requested or not candidate:

        return 0.0

    # Exact match
    if requested == candidate:

        return 1.0

    # Requested name is part of candidate.
    #
    # Example:
    # "intellij idea"
    # "intellij idea community edition"
    if requested in candidate:
        
        return 0.95

    # Candidate is part of requested.
    if candidate in requested:

        return 0.90

    # Compare individual words.
    requestedWords = set(requested.split())

    candidateWords = set( candidate.split())

    commonWords = (requestedWords & candidateWords)

    if requestedWords:

        word_score = (len(commonWords) / len(requestedWords))

        if word_score >= 0.75:

            return 0.85

    # General fuzzy matching.
    return SequenceMatcher(
        isjunk = None,
        a = requested,
        b = candidate
    ).ratio()

