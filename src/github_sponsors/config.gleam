import envoy

pub type Config {
  Config(github_token: String, output_file: String)
}

pub fn load_from_environment() -> Config {
  let assert Ok(github_token) = envoy.get("GH_TOKEN") as "GH_TOKEN must be set"
  let assert Ok(output_file) = envoy.get("GH_OUT_FILE")
    as "GH_OUT_FILE must be set"

  Config(github_token:, output_file:)
}
