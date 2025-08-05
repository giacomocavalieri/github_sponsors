import github_sponsors/config.{type Config}
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/json
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp

const id = "1KlIAj49WRWsM1W_E3XJi5YWvK6bM4QTGwIjePVc-qUc"

const name = "data"

pub type Row {
  Row(estimated_monthly_income: Int, sponsors: Int)
}

pub fn append_current_income(row: Row, config: Config) -> Nil {
  let access_token = get_access_token(config)

  let json =
    json.to_string(
      json.object([
        #("range", json.string(name <> "!A:A")),
        #("majorDimension", json.string("ROWS")),
        #(
          "values",
          json.preprocessed_array([
            json.preprocessed_array([
              json.string(
                timestamp.system_time()
                |> timestamp.to_rfc3339(calendar.utc_offset),
              ),
              json.string(cents_to_dollars(row.estimated_monthly_income)),
              json.int(row.sponsors),
            ]),
          ]),
        ),
      ]),
    )

  let assert Ok(_) =
    request.new()
    |> request.set_scheme(http.Https)
    |> request.set_method(http.Post)
    |> request.set_body(json)
    |> request.set_host("sheets.googleapis.com")
    |> request.set_path(
      "/v4/spreadsheets/" <> id <> "/values/" <> name <> "!A:A:append",
    )
    |> request.set_query([
      #("valueInputOption", "USER_ENTERED"),
      #("access_token", access_token),
    ])
    |> request.prepend_header("content-type", "application/json")
    |> httpc.send

  Nil
}

fn get_access_token(config: Config) -> String {
  let formdata =
    string.concat([
      "client_id=",
      config.client_id,
      "&client_secret=",
      config.client_secret,
      "&refresh_token=",
      config.refresh_token,
      "&grant_type=refresh_token",
    ])

  let assert Ok(response) =
    request.new()
    |> request.set_method(http.Post)
    |> request.set_host("oauth2.googleapis.com")
    |> request.set_path("/token")
    |> request.set_body(formdata)
    |> request.prepend_header(
      "content-type",
      "application/x-www-form-urlencoded",
    )
    |> httpc.send

  let assert Ok(json) =
    json.parse(response.body, using: decode.at(["access_token"], decode.string))

  json
}

fn cents_to_dollars(cents: Int) -> String {
  int.to_string(cents / 100)
  <> ","
  <> string.pad_start(int.to_string(cents % 100), to: 2, with: "0")
}
