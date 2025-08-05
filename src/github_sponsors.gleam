import github_sponsors/config.{type Config}
import github_sponsors/error.{type Error}
import github_sponsors/github
import gleam/int
import gleam/result
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp
import logging
import simplifile

pub fn main() -> Nil {
  logging.configure()
  let config = config.load_from_environment()

  let result =
    result.try(today_report_line(config), fn(line) {
      simplifile.append(line, to: config.output_file)
      |> result.map_error(error.CannotWriteReport(reason: _))
    })

  case result {
    Ok(Nil) -> logging.log(logging.Info, "All good!")
    Error(error) ->
      error.to_string(error)
      |> logging.log(logging.Error, _)
  }
}

fn today_report_line(config: Config) -> Result(String, Error) {
  use information <- result.try(github.get_information(config))
  let github.Information(estimated_monthly_income:, sponsors:) = information

  let #(date, _) =
    timestamp.system_time()
    |> timestamp.to_calendar(calendar.local_offset())

  [
    date_to_string(date),
    int.to_string(sponsors),
    int.to_string(estimated_monthly_income),
  ]
  |> string.join(with: ",")
  |> string.append("\n")
  |> Ok
}

fn date_to_string(date: calendar.Date) -> String {
  let calendar.Date(year:, month:, day:) = date
  [
    int.to_string(year),
    calendar.month_to_int(month)
      |> int.to_string
      |> string.pad_start(to: 2, with: "0"),
    int.to_string(day)
      |> string.pad_start(to: 2, with: "0"),
  ]
  |> string.join(with: "-")
}
