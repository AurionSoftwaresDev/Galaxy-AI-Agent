import re
from pathlib import Path

APP_NAME : str = "Galaxy Browser"
SEARCH_URL : str = "https://www.google.com/search?q="
ACCENT : str = "#1a73e8"
BASE_DIR : Path = Path(__file__).resolve().parent
ICON_PATH : Path = Path("source/assets/app_icon.png")
_HOST_RE : re.Pattern[str] = re.compile(
    r"^(localhost|(\d{1,3}\.){3}\d{1,3}|([\w-]+\.)+[a-zA-Z]{2,})"
    r"(:\d+)?([/?#]\S*)?$"
)


START_TEMPLATE : str = """
<!doctype html>
<html>
    <head>
        <meta charset="utf-8" />
        <title>New Tab</title>
        <style>
            :root {
                --accent: #1a73e8;
            }
            * {
                box-sizing: border-box;
                margin: 0;
            }
            html,
            body {
                height: 100%;
            }
            body {
                font-family:
                    "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
                color: #202124;
                background: radial-gradient(
                    1100px 560px at 50% -8%,
                    #e8f0fe 0%,
                    #ffffff 62%
                );
                display: flex;
                align-items: center;
                justify-content: center;
                overflow: hidden;
            }
            .wrap {
                width: min(640px, 90vw);
                text-align: center;
            }
            .logo {
                width: 84px;
                height: 84px;
                object-fit: contain;
                animation:
                    pop 0.7s cubic-bezier(0.2, 0.9, 0.3, 1.2) both,
                    float 5s ease-in-out 0.8s infinite;
            }
            .mark {
                display: inline-grid;
                place-items: center;
                border-radius: 50%;
                color: #fff;
                font-size: 38px;
                font-weight: 700;
                background: linear-gradient(135deg, #1a73e8, #8ab4f8);
            }
            h1 {
                font-size: 34px;
                font-weight: 600;
                letter-spacing: -0.5px;
                margin: 18px 0 26px;
                animation: up 0.6s 0.15s both;
            }
            form {
                animation: up 0.6s 0.3s both;
            }
            .box {
                display: flex;
                align-items: center;
                height: 54px;
                padding: 0 22px;
                background: #fff;
                border: 1px solid #dfe1e5;
                border-radius: 999px;
                box-shadow: 0 1px 6px rgba(32, 33, 36, 0.08);
                transition:
                    box-shadow 0.25s,
                    border-color 0.25s,
                    transform 0.25s;
            }
            .box:hover {
                box-shadow: 0 2px 12px rgba(32, 33, 36, 0.15);
            }
            .box:focus-within {
                border-color: var(--accent);
                box-shadow: 0 6px 22px rgba(26, 115, 232, 0.25);
                transform: translateY(-1px);
            }
            .box svg {
                flex: none;
                opacity: 0.55;
            }
            input {
                flex: 1;
                border: 0;
                outline: 0;
                background: transparent;
                font-size: 16px;
                margin-left: 12px;
                color: #202124;
            }
            .tiles {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 14px;
                margin-top: 34px;
            }
            .tile {
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 9px;
                padding: 14px 6px;
                border-radius: 14px;
                text-decoration: none;
                color: #3c4043;
                font-size: 13px;
                animation: up 0.6s both;
                transition:
                    background 0.2s,
                    transform 0.2s;
            }
            .tile:nth-child(1) {
                animation-delay: 0.45s;
            }
            .tile:nth-child(2) {
                animation-delay: 0.55s;
            }
            .tile:nth-child(3) {
                animation-delay: 0.65s;
            }
            .tile:nth-child(4) {
                animation-delay: 0.75s;
            }
            .tile:hover {
                background: #f1f3f4;
                transform: translateY(-3px);
            }
            .dot {
                width: 46px;
                height: 46px;
                border-radius: 50%;
                display: grid;
                place-items: center;
                color: #fff;
                font-weight: 600;
                font-size: 18px;
            }
            @keyframes up {
                from {
                    opacity: 0;
                    transform: translateY(14px);
                }
                to {
                    opacity: 1;
                    transform: none;
                }
            }
            @keyframes pop {
                from {
                    opacity: 0;
                    transform: scale(0.6);
                }
                to {
                    opacity: 1;
                    transform: none;
                }
            }
            @keyframes float {
                50% {
                    transform: translateY(-6px);
                }
            }
        </style>
    </head>
    <body>
        <div class="wrap">
            __LOGO__
            <h1>__NAME__</h1>
            <form
                action="https://www.google.com/search"
                method="get"
                autocomplete="off"
            >
                <div class="box">
                    <svg
                        width="20"
                        height="20"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="#202124"
                        stroke-width="2.2"
                        stroke-linecap="round"
                    >
                        <circle cx="10.5" cy="10.5" r="6.5" />
                        <path d="M15.5 15.5L21 21" />
                    </svg>
                    <input name="q" placeholder="Search Google or type a URL" />
                </div>
            </form>
            <div class="tiles">
                <a class="tile" href="https://www.google.com"
                    ><span class="dot" style="background: #4285f4">G</span
                    >Google</a
                >
                <a class="tile" href="https://www.youtube.com"
                    ><span class="dot" style="background: #ff0033">Y</span
                    >YouTube</a
                >
                <a class="tile" href="https://github.com"
                    ><span class="dot" style="background: #24292f">Gh</span
                    >GitHub</a
                >
                <a class="tile" href="https://www.wikipedia.org"
                    ><span class="dot" style="background: #6b7280">W</span
                    >Wikipedia</a
                >
            </div>
        </div>
    </body>
</html>
"""


STYLE : str = """
#strip {
        background: #dee1e6;
    }
    #toolbar {
        background: #ffffff;
    }
    QToolButton {
        border: none;
        border-radius: 17px;
        background: transparent;
    }
    QToolButton:hover {
        background: #e8eaed;
    }
    QToolButton:pressed {
        background: #dadce0;
    }
    QToolButton:disabled {
        background: transparent;
    }
    QToolButton::menu-indicator {
        image: none;
    }
    #strip QToolButton:hover {
        background: #cfd3d9;
    }
    QToolButton#tabclose {
        border-radius: 10px;
    }
    QTabBar {
        background: transparent;
        border: none;
    }
    QTabBar::tab {
        background: transparent;
        color: #5f6368;
        padding: 0 8px 0 12px;
        height: 34px;
        min-width: 120px;
        max-width: 220px;
        margin-top: 6px;
        font-size: 12px;
        border-top-left-radius: 10px;
        border-top-right-radius: 10px;
    }
    QTabBar::tab:selected {
        background: #ffffff;
        color: #202124;
    }
    QTabBar::tab:hover:!selected {
        background: rgba(255, 255, 255, 0.55);
    }
    QMenu {
        background: #ffffff;
        border: 1px solid #dadce0;
        padding: 6px;
        font-size: 13px;
    }
    QMenu::item {
        padding: 8px 30px 8px 16px;
        border-radius: 6px;
        color: #202124;
    }
    QMenu::item:selected {
        background: #f1f3f4;
    }
    QMenu::separator {
        height: 1px;
        background: #e8eaed;
        margin: 6px 8px;
    }
"""