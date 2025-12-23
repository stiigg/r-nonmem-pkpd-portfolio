#' Example 1: Basic SDTM to NONMEM Conversion
#'
#' This example demonstrates:
#' 1. Loading SDTM datasets (PC, EX, DM)
#' 2. Converting to NONMEM format
#' 3. Running validation checks
#' 4. Exporting NONMEM-ready dataset

# Load required packages
library(dplyr)
library(readr)

# Source the conversion functions
source("R/sdtm_to_nonmem.R")
source("R/data_validation.R")

# ============================================================================
# Step 1: Load SDTM Data
# ============================================================================

message("Loading SDTM datasets...")

pc_data <- read_csv("data-raw/sdtm_pc.csv", show_col_types = FALSE)
ex_data <- read_csv("data-raw/sdtm_ex.csv", show_col_types = FALSE)
dm_data <- read_csv("data-raw/sdtm_dm.csv", show_col_types = FALSE)

message("Loaded:")
message("  - PC: ", nrow(pc_data), " concentration records")
message("  - EX: ", nrow(ex_data), " dosing records")
message("  - DM: ", nrow(dm_data), " subjects")

# ============================================================================
# Step 2: Convert to NONMEM Format
# ============================================================================

message("\nConverting to NONMEM format...")

nonmem_data <- create_nonmem_dataset(
  pc_data = pc_data,
  ex_data = ex_data,
  dm_data = dm_data,
  study_id = "STUDY001"
)

message("NONMEM dataset created:")
message("  - Total records: ", nrow(nonmem_data))
message("  - Dosing records (EVID=1): ", sum(nonmem_data$EVID == 1))
message("  - Observation records (EVID=0): ", sum(nonmem_data$EVID == 0))
message("  - Subjects: ", length(unique(nonmem_data$ID)))

# Preview first few records per subject
message("\nFirst 10 records:")
print(head(nonmem_data, 10))

# ============================================================================
# Step 3: Validate NONMEM Dataset
# ============================================================================

message("\n" , paste(rep("=", 60), collapse = ""))
message("Running validation checks...")
message(paste(rep("=", 60), collapse = ""))

validation_results <- validate_nonmem_data(nonmem_data)

# Print validation report
print_validation_report(validation_results)

# ============================================================================
# Step 4: Export NONMEM Dataset
# ============================================================================

if (validation_results$valid) {
  output_dir <- "data"
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  
  output_file <- file.path(output_dir, "nonmem_pk_dataset.csv")
  write_nonmem_data(nonmem_data, output_file)
  
  message("\n✅ SUCCESS: NONMEM dataset ready for analysis")
  message("Output file: ", output_file)
  
} else {
  message("\n❌ VALIDATION FAILED: Please fix errors before export")
  message("Errors found:")
  for (err in validation_results$errors) {
    message("  - ", err)
  }
}

# ============================================================================
# Step 5: Generate Summary Statistics
# ============================================================================

message("\n=== Dataset Summary by Dose Group ===")

summary_by_dose <- nonmem_data %>%
  filter(EVID == 0, !is.na(DV)) %>%
  left_join(dm_data %>% select(USUBJID, ARMCD), by = "USUBJID") %>%
  group_by(ARMCD) %>%
  summarise(
    N_subjects = n_distinct(ID),
    N_observations = n(),
    Mean_conc = round(mean(DV, na.rm = TRUE), 2),
    SD_conc = round(sd(DV, na.rm = TRUE), 2),
    Max_conc = round(max(DV, na.rm = TRUE), 2),
    .groups = "drop"
  )

print(summary_by_dose)

message("\n=== Example Complete ===")
