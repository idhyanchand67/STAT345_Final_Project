# ============================================================================
# 02_process_roads_function.R
# Purpose: Reusable function for processing county road files.
#          Each team member sources this, then runs their own person_X script.
#
# Author: [Blake]
# Date: [12/03]
# ============================================================================

library(sf)
library(dplyr)
library(stringr)

# ============================================================================
# Main Function: process_county_roads()
# ============================================================================

process_county_roads <- function(geoid, state_fips, cache_dir = "data_raw/roads") {
  
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  }
  
  tryCatch({
    url <- paste0(
      "https://www2.census.gov/geo/tiger/TIGER2023/ROADS/",
      "tl_2023_", geoid, "_roads.zip"
    )
    
    local_zip <- file.path(cache_dir, paste0(geoid, "_roads.zip"))
    local_shp <- file.path(cache_dir, paste0("tl_2023_", geoid, "_roads.shp"))
    
    if (!file.exists(local_shp)) {
      download.file(url, local_zip, mode = "wb", quiet = TRUE)
      unzip(local_zip, exdir = cache_dir, overwrite = TRUE)
      file.remove(local_zip)
    }
    
    roads_sf <- st_read(local_shp, quiet = TRUE)
    
    if (nrow(roads_sf) == 0) {
      return(NULL)
    }
    
    # List of valid road suffixes to keep
    valid_suffixes <- c(
      "ALY","AVE","BLVD","BYU","BND","BR","BRG","BRK","BRKS","BG","BGS","BYP",
      "CSWY","CTR","CTRS","CIR","CIRS","CLF","CLFS","COR","CORS","CRSE","CT",
      "CTS","CV","CVS","CYN","DR","DRS","EST","ESTS","EXPY","EXT","EXTS","FALL",
      "FLS","FRY","FRD","FRDS","FRG","FRGS","FWY","GDN","GDNS","GTWY","GLN",
      "GLNS","GRN","GRNS","GRV","GRVS","HBR","HBRS","HVN","HTS","HWY","HL","HLS",
      "HOLW","INLT","IS","ISS","JCT","JCTS","KNL","KNLS","LK","LKS","LN","LNDG",
      "LOOP","MALL","MDW","MDWS","MEWS","ML","MLS","MTWY","MT","MTN","MTNS",
      "NCK","OPAS","ORCH","OVAL","PARK","PKWY","PKWYS","PASS","PATH","PIKE",
      "PL","PLN","PLNS","PLZ","PT","PTS","RADL","RAMP","RD","RDS","RIV","RUN",
      "SHL","SHLS","SHR","SHRS","SKWY","SPG","SPGS","SPUR","SQ","SQS","ST",
      "STA","STRA","STRM","STS","TER","TPKE","TRAK","TRL","TRLR","TUNL","UN",
      "UNS","VLY","VLYS","VIA","VW","VWS","WALK","WAY","WAYS","WL","WLS"
    )
    
    
    roads_sf <- roads_sf %>%
      mutate(
        SUFFIX = str_extract(FULLNAME, "\\b\\w+$"),
        SUFFIX = str_to_upper(SUFFIX)
      ) %>%
      filter(SUFFIX %in% valid_suffixes)  # Only keep valid suffixes
    
    
    suffix_counts <- roads_sf %>%
      st_drop_geometry() %>%
      group_by(SUFFIX) %>%
      summarise(COUNT = n(), .groups = "drop") %>%
      arrange(desc(COUNT))
    
    total_roads <- sum(suffix_counts$COUNT)
    
    result <- suffix_counts %>%
      mutate(
        GEOID = geoid,
        TOTAL_ROADS = total_roads,
        PCT = round(100 * COUNT / TOTAL_ROADS, 2)
      ) %>%
      select(GEOID, SUFFIX, COUNT, TOTAL_ROADS, PCT)
    
    return(result)
    
  }, error = function(e) {
    cat("  ✗ Error processing GEOID", geoid, ":", e$message, "\n")
    return(NULL)
  })
  
}

# ============================================================================
# Batch Processing Function: process_state_roads()
# ============================================================================

process_state_roads <- function(
    state_fips,
    batch_size = 50,
    output_file = NULL,
    counties_df = NULL
) {
  
  if (is.null(counties_df)) {
    counties_df <- readRDS("data_processed/counties_us_shift_5070.rds")
  }
  
  state_counties <- counties_df %>%
    st_drop_geometry() %>%
    filter(STATEFP == state_fips) %>%
    pull(GEOID)
  
  # Map FIPS to state abbreviations
  state_abbr_map <- c(
    "01" = "al", "02" = "ak", "04" = "az", "05" = "ar", "06" = "ca", 
    "08" = "co", "09" = "ct", "10" = "de", "12" = "fl", "13" = "ga",
    "15" = "hi", "16" = "id", "17" = "il", "18" = "in", "19" = "ia", 
    "20" = "ks", "21" = "ky", "22" = "la", "23" = "me", "24" = "md",
    "25" = "ma", "26" = "mi", "27" = "mn", "28" = "ms", "29" = "mo", 
    "30" = "mt", "31" = "ne", "32" = "nv", "33" = "nh", "34" = "nj",
    "35" = "nm", "36" = "ny", "37" = "nc", "38" = "nd", "39" = "oh", 
    "40" = "ok", "41" = "or", "42" = "pa", "44" = "ri", "45" = "sc",
    "46" = "sd", "47" = "tn", "48" = "tx", "49" = "ut", "50" = "vt", 
    "51" = "va", "53" = "wa", "54" = "wv", "55" = "wi", "56" = "wy", 
    "11" = "dc"
  )
  
  state_abbr <- state_abbr_map[state_fips]
  if (is.na(state_abbr)) state_abbr <- tolower(substr(state_fips, 1, 2))
  
  cat("\n")
  cat("========================================\n")
  cat("Processing roads for FIPS ", state_fips, " (Counties: ", length(state_counties), ")\n", sep = "")
  cat("Batch size: ", batch_size, "\n", sep = "")
  cat("========================================\n\n")
  
  if (is.null(output_file)) {
    if (!dir.exists("data_processed")) dir.create("data_processed", recursive = TRUE)
    output_file <- paste0("data_processed/road_suffixes_", state_abbr, ".csv")
  }
  
  all_results <- NULL
  total_processed <- 0
  
  num_batches <- ceiling(length(state_counties) / batch_size)
  
  for (batch_num in 1:num_batches) {
    start_idx <- ((batch_num - 1) * batch_size) + 1
    end_idx <- min(batch_num * batch_size, length(state_counties))
    batch_geoids <- state_counties[start_idx:end_idx]
    
    cat("Batch ", batch_num, "/", num_batches, " (counties ", start_idx, "-", end_idx, "):\n", sep = "")
    
    batch_results <- NULL
    
    for (geoid in batch_geoids) {
      cat("  Processing GEOID ", geoid, "... ", sep = "")
      
      county_result <- process_county_roads(geoid, state_fips)
      
      if (!is.null(county_result)) {
        if (is.null(batch_results)) {
          batch_results <- county_result
        } else {
          batch_results <- bind_rows(batch_results, county_result)
        }
        cat("✓ (", nrow(county_result), " suffixes)\n", sep = "")
      } else {
        cat("✗ (skipped)\n")
      }
    }
    
    if (!is.null(batch_results)) {
      all_results <- bind_rows(all_results, batch_results)
      total_processed <- total_processed + nrow(batch_results)
    }
    
    if (!is.null(batch_results)) {
      if (batch_num == 1) {
        write.csv(all_results, output_file, row.names = FALSE)
      } else {
        write.table(batch_results, output_file, sep = ",", 
                    col.names = FALSE, row.names = FALSE, append = TRUE)
      }
      
      cat("  ✓ Batch saved to CSV\n\n")
    }
    
    rm(batch_results, county_result)
    gc()
  }
  
  cat("========================================\n")
  cat("State complete (FIPS ", state_fips, ")\n", sep = "")
  cat("  • Total rows: ", total_processed, "\n", sep = "")
  cat("  • Output file: ", output_file, "\n", sep = "")
  cat("========================================\n\n")
  
  return(invisible(output_file))
}

cat("✓ Step 2 functions loaded successfully\n")
cat("  Use process_state_roads(state_fips) to process a state\n")
