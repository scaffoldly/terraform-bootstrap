locals {
  api_subdomain = "api"

  stages = ["nonlive", "live"]

  nonlive = {
    domain = "scaffoldly.dev"
  }

  live = {
    domain = "scaffold.ly"
  }

  serverless_apis = {
    example = {
      asdf = "foo" # TODO: Placeholder remove
    }
  }
}
