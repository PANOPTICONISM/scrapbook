use std::env;

#[derive(Debug, Clone)]
pub struct Config {
    pub database_url: String,
    pub api_token: String,
    pub host: String,
    pub port: u16,
}

impl Config {
    pub fn from_env() -> anyhow::Result<Self> {
        let api_token = env::var("SCRAPBOOK_TOKEN")
            .map_err(|_| anyhow::anyhow!("SCRAPBOOK_TOKEN env var is required"))?;

        if api_token.is_empty() {
            anyhow::bail!("SCRAPBOOK_TOKEN must not be empty");
        }

        Ok(Self {
            database_url: env::var("DATABASE_URL")
                .unwrap_or_else(|_| "sqlite:./scrapbook.db".to_string()),
            api_token,
            host: env::var("HOST").unwrap_or_else(|_| "0.0.0.0".to_string()),
            port: env::var("PORT")
                .unwrap_or_else(|_| "8080".to_string())
                .parse()
                .unwrap_or(8080),
        })
    }
}
