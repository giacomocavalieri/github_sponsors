import github_sponsors/config.{type Config}
import github_sponsors/error.{type Error, CannotParseResponse, CannotSendRequest}
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/result

pub type Information {
  Information(estimated_monthly_income: Int, sponsors: Int)
}

pub fn get_information(config: Config) -> Result(Information, Error) {
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

  use response <- result.try(
    request.new()
    |> request.set_method(http.Post)
    |> request.set_host("api.github.com")
    |> request.set_path("/graphql")
    |> request.prepend_header("content-type", "application/json")
    |> request.prepend_header("authorization", "bearer " <> config.github_token)
    |> request.set_body(query)
    |> httpc.send
    |> result.map_error(CannotSendRequest(reason: _)),
  )

  let information_decoder =
    decode.at(["data", "viewer"], {
      use sponsors <- decode.subfield(["sponsors", "totalCount"], decode.int)
      use income <- decode.field(
        "monthlyEstimatedSponsorsIncomeInCents",
        decode.int,
      )
      decode.success(Information(estimated_monthly_income: income, sponsors:))
    })

  json.parse(response.body, information_decoder)
  |> result.map_error(CannotParseResponse(body: response.body, reason: _))
}
