#' Example 2: Population PK Dataset with Covariates
#'
#' This example demonstrates:
#' 1. Creating a complete PopPK analysis dataset
#' 2. Handling covariates (continuous and categorical)
#' 3. Creating derived variables
#' 4. Exporting for NONMEM population analysis

library(dplyr)
library(readr)

source("R/sdtm_to_nonmem.R")
source("R/data_validation.R")

# ============================================================================
# Load Data
# ============================================================================

pc_data <- read_csv("data-raw/sdtm_pc.csv", show_col_types = FALSE)
ex_data <- read_csv("data-raw/sdtm_ex.csv", show_col_types = FALSE)
dm_data <- read_csv("data-raw/sdtm_dm.csv", show_col_types = FALSE)

# ============================================================================
# Create Base NONMEM Dataset
# ============================================================================

nonmem_data <- create_nonmem_dataset(
  pc_data = pc_data,
  ex_data = ex_data,
  dm_data = dm_data,
  study_id = "STUDY001"
)

# ============================================================================
# Add Population PK Covariates
# ============================================================================

message("Adding PopPK covariates...")

# Merge additional demographic variables
popPK_data <- nonmem_data %>%
  left_join(
    dm_data %>% select(USUBJID, WEIGHT, HEIGHT, BMI, RACE),
    by = "USUBJID"
  ) %>%
  mutate(
    # Continuous covariates (normalized around population median)
    WT = WEIGHT,
    WTN = WEIGHT / median(dm_data$WEIGHT, na.rm = TRUE),  # Normalized weight
    HT = HEIGHT,
    BMIN = BMI,
    
    # Categorical covariates
    RACEN = case_when(
      RACE == "WHITE" ~ 1,
      RACE == "BLACK OR AFRICAN AMERICAN" ~ 2,
      RACE == "ASIAN" ~ 3,
      TRUE ~ 9
    ),
    
    # Dose level as categorical covariate
    DOSE = AMT,
    DOSEN = case_when(
      AMT == 100 ~ 1,
      AMT == 300 ~ 2,
      AMT == 600 ~ 3,
      TRUE ~ 0
    ),
    
    # Create occasion variable (all dose 1 in this single-dose study)
    OCC = 1,
    
    # Flag for first observation per subject
    FIRSTOBS = as.integer(TIME == min(TIME[EVID == 0], na.rm = TRUE)),
    
    # Baseline covariate flag
    BL = as.integer(TIME == 0 & EVID == 1)
  )

# ============================================================================
# Add Derived Time Variables
# ============================================================================

popPK_data <- popPK_data %>%
  group_by(ID) %>%
  mutate(
    # Time after dose (TAD) - same as TIME in single dose
    TAD = TIME,
    
    # Time of first observation
    TIMEOBS1 = min(TIME[EVID == 0], na.rm = TRUE),
    
    # Study day
    DAY = ceiling(TIME / 24)
  ) %>%
  ungroup()

# ============================================================================
# Reorder Columns for NONMEM
# ============================================================================

popPK_data <- popPK_data %>%
  select(
    # Core NONMEM variables
    ID, TIME, TAD, AMT, DV, EVID, CMT, MDV,
    
    # Continuous covariates
    AGE, WT, WTN, HT, BMIN,
    
    # Categorical covariates
    SEXN, RACEN, DOSEN,
    
    # Derived variables
    OCC, DAY, FIRSTOBS, BL,
    
    # Identifiers
    USUBJID, STUDY, ROW
  )

# ============================================================================
# Validate and Export
# ============================================================================

message("\nValidating PopPK dataset...")
validation <- validate_nonmem_data(popPK_data)
print_validation_report(validation)

if (validation$valid) {
  output_file <- "data/nonmem_popPK_dataset.csv"
  write_nonmem_data(popPK_data, output_file)
  
  message("\n=== PopPK Dataset Summary ===")
  message("Covariates included:")
  message("  Continuous: AGE, WT, WTN, HT, BMIN")
  message("  Categorical: SEXN, RACEN, DOSEN")
  message("  Derived: TAD, OCC, DAY, FIRSTOBS, BL")
  
  # Covariate summary
  cov_summary <- popPK_data %>%
    filter(EVID == 1) %>%  # One row per subject
    summarise(
      N = n(),
      Age_mean = round(mean(AGE), 1),
      Age_range = paste(min(AGE), "-", max(AGE)),
      Weight_mean = round(mean(WT), 1),
      Weight_range = paste(round(min(WT), 1), "-", round(max(WT), 1)),
      Sex_M = sum(SEXN == 1),
      Sex_F = sum(SEXN == 2)
    )
  
  message("\n=== Covariate Distribution ===")
  print(cov_summary)
  
  message("\n✅ PopPK dataset ready for NONMEM analysis")
  message("File: ", output_file)
}
