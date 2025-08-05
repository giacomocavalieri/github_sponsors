import github_sponsors/config
import github_sponsors/github
import github_sponsors/sheet

pub fn main() -> Nil {
  let config = config.load_from_environment()
  let github.Information(estimated_monthly_income:, sponsors:) =
    github.get_information(config)

  let row = sheet.Row(estimated_monthly_income:, sponsors:)
  sheet.append_current_income(row, config)
}
