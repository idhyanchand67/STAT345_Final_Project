# ============================================================================
# 02_combine_results.R
# Purpose: Combine individual state road summaries into one master file
#          AND identify most common road suffix for each county
#
# Author: [Blake - Shared Final Step]
# Date: [12/03]
# Instructions:
#   1. Wait until all three people have finished processing
#   2. Run this script (takes ~5 minutes)
#   3. Check data_processed/ for combined CSV files
# ============================================================================

library(dplyr)
library(tidyr)

cat("Combining Road Results\n")


cat("Looking for individual state CSV files in data_processed/...\n\n")

csv_files <- list.files(
  "data_processed",
  pattern = "^road_suffixes_[a-z]{2}\\.csv$",
  full.names = TRUE
)

cat("Found ", length(csv_files), " state files:\n", sep = "")
for (f in sort(csv_files)) {
  cat("  ✓ ", basename(f), "\n", sep = "")
}
cat("\n")

if (length(csv_files) == 0) {
  stop("No road_suffixes_*.csv files found! Did all team members finish processing?")
}

# ============================================================================
# Read and combine all CSV files
# ============================================================================

cat("Combining all state results...\n")

all_roads <- NULL

for (file in csv_files) {
  state_abbr <- gsub("^.*road_suffixes_([a-z]{2})\\.csv$", "\\1", file)
  
  # Read CSV
  state_data <- read.csv(file, stringsAsFactors = FALSE)
  
  # Combine
  if (is.null(all_roads)) {
    all_roads <- state_data
  } else {
    all_roads <- bind_rows(all_roads, state_data)
  }
  
  cat("  ✓ Loaded ", nrow(state_data), " rows from ", basename(file), "\n", sep = "")
}

cat("\nTotal rows combined: ", nrow(all_roads), "\n", sep = "")
cat("Total unique counties: ", n_distinct(all_roads$GEOID), "\n\n", sep = "")

# ============================================================================
# Find most common suffix for each county
# ============================================================================

cat("Finding most common road suffix for each county...\n\n")

most_common_suffix <- all_roads %>%
  group_by(GEOID) %>%
  arrange(GEOID, desc(COUNT)) %>%
  slice(1) %>%
  ungroup() %>%
  select(GEOID, SUFFIX, COUNT, TOTAL_ROADS, PCT)

cat("✓ Created county-level summary\n")
cat("  Rows: ", nrow(most_common_suffix), "\n", sep = "")
cat("  Columns: ", paste(names(most_common_suffix), collapse = ", "), "\n\n", sep = "")



cat("Saving results...\n")

write.csv(
  all_roads,
  "data_processed/road_suffixes_all_detailed.csv",
  row.names = FALSE
)
cat("✓ Detailed results: data_processed/road_suffixes_all_detailed.csv\n")
cat("  (All road suffixes for all counties)\n\n")

write.csv(
  most_common_suffix,
  "data_processed/road_suffixes_most_common.csv",
  row.names = FALSE
)
cat("✓ Summary results: data_processed/road_suffixes_most_common.csv\n")
cat("  (Most common suffix per county)\n\n")

# ============================================================================
# Summary statistics
# ============================================================================

cat("========================================\n")
cat("Summary Statistics\n")
cat("========================================\n")
cat("Total rows (all suffixes): ", nrow(all_roads), "\n", sep = "")
cat("Total unique counties: ", n_distinct(all_roads$GEOID), "\n", sep = "")
cat("Total unique road suffixes: ", n_distinct(all_roads$SUFFIX), "\n", sep = "")
cat("\nTop 20 most common road suffixes (overall):\n")
print(all_roads %>%
  group_by(SUFFIX) %>%
  summarise(TOTAL_COUNT = sum(COUNT), .groups = "drop") %>%
  arrange(desc(TOTAL_COUNT)) %>%
  head(20))


