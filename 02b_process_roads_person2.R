# ============================================================================
# 02b_process_roads_person2.R
# Purpose: Process Midwest/Central US roads (TX, OK, KS, NE, SD, ND, CO, WY, MT)
#          ~500 counties total
#
# Author: [Blake]
# Date: [12/03]
# ============================================================================

library(sf)
library(dplyr)

cat("Loading shared functions from 02_process_roads_function.R...\n\n")
source("02_process_roads_function.R")

cat("Loading counties data from Step 1...\n")
counties_df <- readRDS("data_processed/counties_us_shift_5070.rds")
cat("✓ Loaded counties data\n\n")

# Person 2 processes: TX, OK, KS, NE, SD, ND, CO, WY, MT
midwest_states <- c(
  "48",  # Texas
  "40",  # Oklahoma
  "20",  # Kansas
  "31",  # Nebraska
  "46",  # South Dakota
  "38",  # North Dakota
  "08",  # Colorado
  "56",  # Wyoming
  "30"   # Montana
)

cat("========================================\n")
cat("PERSON 2: Midwest/Central US Road Processing\n")
cat("========================================\n")
cat("States to process (FIPS codes):\n")
cat("  48 (Texas)\n")
cat("  40 (Oklahoma)\n")
cat("  20 (Kansas)\n")
cat("  31 (Nebraska)\n")
cat("  46 (South Dakota)\n")
cat("  38 (North Dakota)\n")
cat("  08 (Colorado)\n")
cat("  56 (Wyoming)\n")
cat("  30 (Montana)\n")

total_counties <- counties_df %>%
  st_drop_geometry() %>%
  filter(STATEFP %in% midwest_states) %>%
  nrow()

cat("\nTotal counties: ", total_counties, "\n", sep = "")
cat("Estimated time: 30-60 minutes\n")
cat("========================================\n\n")

# Process each state
for (state_fips in midwest_states) {
  process_state_roads(
    state_fips = state_fips,
    batch_size = 50,
    output_file = NULL,
    counties_df = counties_df
  )
}

cat("\n")
cat("========================================\n")
cat("PERSON 2: All Midwest/Central States Complete!\n")
cat("========================================\n")
cat("Output files created in data_processed/:\n")
cat("  • road_suffixes_tx.csv\n")
cat("  • road_suffixes_ok.csv\n")
cat("  • road_suffixes_ks.csv\n")
cat("  • road_suffixes_ne.csv\n")
cat("  • road_suffixes_sd.csv\n")
cat("  • road_suffixes_nd.csv\n")
cat("  • road_suffixes_co.csv\n")
cat("  • road_suffixes_wy.csv\n")
cat("  • road_suffixes_mt.csv\n")
cat("\nNext step: Wait for Person 1 & 3 to finish\n")
cat("Final step: Run 02_combine_results.R\n")
cat("========================================\n")
