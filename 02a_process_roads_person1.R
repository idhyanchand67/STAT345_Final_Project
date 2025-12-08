# ============================================================================
# 02a_process_roads_person1.R
# Purpose: Process Western US roads (CA, OR, WA, NV, ID, UT, AZ, NM)
#          ~520 counties total
#
# Author: Blake
# Date: 12/03/2025
# ============================================================================

library(sf)
library(dplyr)

cat("Loading shared functions from 02_process_roads_function.R...\n\n")
source("R/02_process_roads_function.R")

cat("Loading counties data from Step 1...\n")
counties_df <- readRDS("data_processed/counties_us_shift_5070.rds")
cat("✓ Loaded counties data\n\n")

# Person 1 processes: CA, OR, WA, NV, ID, UT, AZ, NM
western_states <- c(
  "06",  # California
  "41",  # Oregon
  "53",  # Washington
  "32",  # Nevada
  "16",  # Idaho
  "49",  # Utah
  "04",  # Arizona
  "35"   # New Mexico
)

cat("========================================\n")
cat("PERSON 1: Western US Road Processing\n")
cat("========================================\n")
cat("States to process (FIPS codes):\n")
cat("  06 (California)\n")
cat("  41 (Oregon)\n")
cat("  53 (Washington)\n")
cat("  32 (Nevada)\n")
cat("  16 (Idaho)\n")
cat("  49 (Utah)\n")
cat("  04 (Arizona)\n")
cat("  35 (New Mexico)\n")

total_counties <- counties_df %>%
  st_drop_geometry() %>%
  filter(STATEFP %in% western_states) %>%
  nrow()

cat("\nTotal counties: ", total_counties, "\n", sep = "")
cat("Estimated time: 30-60 minutes\n")
cat("========================================\n\n")

# Process each state
for (state_fips in western_states) {
  process_state_roads(
    state_fips = state_fips,
    batch_size = 50,
    output_file = NULL,
    counties_df = counties_df
  )
}

cat("\n")
cat("========================================\n")
cat("PERSON 1: All Western States Complete!\n")
cat("========================================\n")
cat("Output files created in data_processed/:\n")
cat("  • road_suffixes_ca.csv\n")
cat("  • road_suffixes_or.csv\n")
cat("  • road_suffixes_wa.csv\n")
cat("  • road_suffixes_nv.csv\n")
cat("  • road_suffixes_id.csv\n")
cat("  • road_suffixes_ut.csv\n")
cat("  • road_suffixes_az.csv\n")
cat("  • road_suffixes_nm.csv\n")
cat("\nNext step: Wait for Person 2 & 3 to finish\n")
cat("Final step: Run 02_combine_results.R\n")
cat("========================================\n")
