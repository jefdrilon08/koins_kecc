APP_HOST = ENV.fetch("APP_HOST")
APP_PIPELINE = ENV.fetch("APP_PIPELINE")
CLIP_ACCOUNTING_CODE_ID = "af83062d-628a-4fdd-acfd-bdebe2696513"
LIST_PAGE_SIZE = 50
REDIS_URL = ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }
REINSURANCE_THRESHOLD_AMOUNT = 200_000
ROLLBAR_ACCESS_TOKEN = ENV.fetch("ROLLBAR_ACCESS_TOKEN")
SIDEKIQ_WEB_PATH = "/8229991ea9a2fb6f"

MONTHS_FOR_SELECT = [
  ["January", 1],
  ["February", 2],
  ["March", 3],
  ["April", 4],
  ["May", 5],
  ["June", 6],
  ["July", 7],
  ["August", 8],
  ["September", 9],
  ["October", 10],
  ["November", 11],
  ["December", 12],
]
