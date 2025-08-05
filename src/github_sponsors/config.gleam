import envoy

pub type Config {
  Config(
    client_id: String,
    client_secret: String,
    refresh_token: String,
    github_token: String,
  )
}

pub fn load_from_environment() -> Config {
  let assert Ok(client_id) = envoy.get("GCP_CLIENT_ID")
  let assert Ok(client_secret) = envoy.get("GCP_CLIENT_SECRET")
  let assert Ok(refresh_token) = envoy.get("GCP_REFRESH_TOKEN")
  let assert Ok(github_token) = envoy.get("GH_TOKEN")
  Config(client_id:, client_secret:, refresh_token:, github_token:)
}
