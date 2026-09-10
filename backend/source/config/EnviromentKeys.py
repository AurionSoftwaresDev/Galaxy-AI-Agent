import source.config.configs as Configs

ENVRIOMENTAL_KEYS : dict[str, (str | None)] = {
    "geminiAPIKey": Configs.getGeminiAPIKey(),
    "mistralAPIKey": Configs.getMistralAPIKey(),
    "smtpPort" : Configs.getSMTPPORT(),
    "smtpSenderEmail": Configs.getSMTPSenderEmail(),
    "smtpSenderPassword": Configs.getSMTPSenderPassword(),
    "smtpHost": Configs.getSMTPServerHost()
}