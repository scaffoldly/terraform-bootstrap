locals {
  api_subdomain = "api"

  nonlive = {
    domain = "scaffoldly.dev"
  }

  live = {
    domain = "scaffold.ly"
  }

  serverless_apis = {
    example = {
      stages = ["nonlive", "live"]
    }
  }
}
