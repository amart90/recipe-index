library(googlesheets4)
library(dplyr)

# Load sheet ID from environment variable
googlesheets4::gs4_deauth()
sheet_id <- Sys.getenv("SHEET_ID")
if (sheet_id == "") stop("Missing SHEET_ID environment variable.")

# Read live sheet data
live <- read_sheet(
  sheet_id,
  sheet = "Recipe table",
  trim_ws = TRUE
) |>
  arrange_all()

# Path to cached .rds file
cache_file <- "data_cache.rds"

if (file.exists(cache_file)) {
  cached <- readRDS(cache_file) |>
    arrange_all()
  if (identical(live, cached)) {
    message("No changes found.")
    quit(status = 0)  # success → skip build
  } else {
    message("Changes found. Updating .rds cache.")
    saveRDS(live, cache_file)
    quit(status = 99)  # changes → trigger rebuild
  }
} else {
  message("First run: saving .rds cache.")
  saveRDS(live, cache_file)
  quit(status = 99)  # first run → trigger build
}