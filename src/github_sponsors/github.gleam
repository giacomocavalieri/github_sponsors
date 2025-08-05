import github_sponsors/config.{type Config}
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/json

pub type Information {
  Information(estimated_monthly_income: Int, sponsors: Int)
}

pub fn get_information(config: Config) -> Information {
  let query =
    "query {
  viewer {
    monthlyEstimatedSponsorsIncomeInCents
    sponsors {
      totalCount
    }
  }
}"

  let query = json.to_string(json.object([#("query", json.string(query))]))

  let assert Ok(response) =
    request.new()
    |> request.set_method(http.Post)
    |> request.set_host("api.github.com")
    |> request.set_path("/graphql")
    |> request.prepend_header("content-type", "application/json")
    |> request.prepend_header("authorization", "bearer " <> config.github_token)
    |> request.set_body(query)
    |> httpc.send

  let viewer_decoder = {
    use sponsors <- decode.subfield(["sponsors", "totalCount"], decode.int)
    use income <- decode.field(
      "monthlyEstimatedSponsorsIncomeInCents",
      decode.int,
    )
    decode.success(Information(estimated_monthly_income: income, sponsors:))
  }

  let assert Ok(information) =
    json.parse(response.body, decode.at(["data", "viewer"], viewer_decoder))

  information
}
