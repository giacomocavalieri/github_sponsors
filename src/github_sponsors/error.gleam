import gleam/httpc
import gleam/json
import simplifile

pub type Error {
  CannotParseResponse(body: String, reason: json.DecodeError)
  CannotSendRequest(reason: httpc.HttpError)
  CannotWriteReport(reason: simplifile.FileError)
}

pub fn to_string(error: Error) -> String {
  case error {
    CannotParseResponse(body: _, reason: _) -> "cannot parse GitHub response"
    CannotSendRequest(reason: _) -> "cannot send GitHub request"
    CannotWriteReport(reason: _) -> "cannot write report to file"
  }
}
