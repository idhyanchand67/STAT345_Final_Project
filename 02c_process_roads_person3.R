# ============================================================================
# 02c_process_roads_person3.R
# Purpose: Process Eastern US roads (all remaining states + DC)
#          FL, GA, SC, NC, VA, WV, PA, NY, VT, NH, ME, MA, RI, CT, NJ, DE,
#          MD, OH, IN, IL, MI, WI, MN, IA, MO, AR, LA, MS, TN, KY, AL, 
#          AK, HI, DC (~730 counties)
#
# Author: [Person 3 Name]
# Date: [Date]
# ============================================================================

library(sf)
library(dplyr)

cat("Loading shared functions from 02_process_roads_function.R...\n\n")
source("R/02_process_roads_function.R")

cat("Loading counties data from Step 1...\n")
counties_df <- readRDS("data_processed/counties_us_shift_5070.rds")
cat("✓ Loaded counties data\n\n")

# Person 3 processes: All remaining states (~730 counties)
eastern_states <- c(
  "12",  # Florida
  "13",  # Georgia
  "45",  # South Carolina
  "37",  # North Carolina
  "51",  # Virginia
  "54",  # West Virginia
  "42",  # Pennsylvania
  "36",  # New York
  "50",  # Vermont
  "33",  # New Hampshire
  "23",  # Maine
  "25",  # Massachusetts
  "44",  # Rhode Island
  "09",  # Connecticut
  "34",  # New Jersey
  "10",  # Delaware
  "24",  # Maryland
  "39",  # Ohio
  "18",  # Indiana
  "17",  # Illinois
  "26",  # Michigan
  "55",  # Wisconsin
  "27",  # Minnesota
  "19",  # Iowa
  "29",  # Missouri
  "05",  # Arkansas
  "22",  # Louisiana
  "28",  # Mississippi
  "47",  # Tennessee
  "21",  # Kentucky
  "01",  # Alabama
  "02",  # Alaska
  "15",  # Hawaii
  "11"   # District of Columbia
)

cat("========================================\n")
cat("PERSON 3: Eastern US Road Processing\n")
cat("========================================\n")
cat("States to process (FIPS codes):\n")
cat("  12 (Florida)\n")
cat("  13 (Georgia)\n")
cat("  45 (South Carolina)\n")
cat("  37 (North Carolina)\n")
cat("  51 (Virginia)\n")
cat("  54 (West Virginia)\n")
cat("  42 (Pennsylvania)\n")
cat("  36 (New York)\n")
cat("  50 (Vermont)\n")
cat("  33 (New Hampshire)\n")
cat("  23 (Maine)\n")
cat("  25 (Massachusetts)\n")
cat("  44 (Rhode Island)\n")
cat("  09 (Connecticut)\n")
cat("  34 (New Jersey)\n")
cat("  10 (Delaware)\n")
cat("  24 (Maryland)\n")
cat("  39 (Ohio)\n")
cat("  18 (Indiana)\n")
cat("  17 (Illinois)\n")
cat("  26 (Michigan)\n")
cat("  55 (Wisconsin)\n")
cat("  27 (Minnesota)\n")
cat("  19 (Iowa)\n")
cat("  29 (Missouri)\n")
cat("  05 (Arkansas)\n")
cat("  22 (Louisiana)\n")
cat("  28 (Mississippi)\n")
cat("  47 (Tennessee)\n")
cat("  21 (Kentucky)\n")
cat("  01 (Alabama)\n")
cat("  02 (Alaska)\n")
cat("  15 (Hawaii)\n")
cat("  11 (District of Columbia)\n")

total_counties <- counties_df %>%
  st_drop_geometry() %>%
  filter(STATEFP %in% eastern_states) %>%
  nrow()

cat("\nTotal counties: ", total_counties, "\n", sep = "")
cat("Estimated time: 45-90 minutes\n")
cat("========================================\n\n")

# Process each state
for (state_fips in eastern_states) {
  process_state_roads(
    state_fips = state_fips,
    batch_size = 50,
    output_file = NULL,
    counties_df = counties_df
  )
}

cat("\n")
cat("========================================\n")
cat("PERSON 3: All Eastern States Complete!\n")
cat("========================================\n")
cat("Output files created in data_processed/:\n")
cat("  • Multiple CSV files (one per state)\n")
cat("  • See data_processed/ folder for all road_suffixes_*.csv files\n")
cat("\nNext step: Wait for Person 1 & 2 to finish\n")
cat("Final step: Run 02_combine_results.R\n")
cat("========================================\n")
