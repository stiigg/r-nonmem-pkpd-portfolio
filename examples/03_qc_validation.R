#' Example 3: Comprehensive QC and Validation Workflow
#'
#' This example demonstrates:
#' 1. Detailed validation checks
#' 2. Data quality assessment
#' 3. Flagging potential issues
#' 4. Generating QC reports

library(dplyr)
library(readr)
library(ggplot2)

source("R/sdtm_to_nonmem.R")
source("R/data_validation.R")
source("R/pk_calculations.R")

# ============================================================================
# Load and Convert Data
# ============================================================================

pc_data <- read_csv("data-raw/sdtm_pc.csv", show_col_types = FALSE)
ex_data <- read_csv("data-raw/sdtm_ex.csv", show_col_types = FALSE)
dm_data <- read_csv("data-raw/sdtm_dm.csv", show_col_types = FALSE)

nonmem_data <- create_nonmem_dataset(
  pc_data = pc_data,
  ex_data = ex_data,
  dm_data = dm_data,
  study_id = "STUDY001"
)

# ============================================================================
# Run Comprehensive Validation
# ============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("COMPREHENSIVE QC VALIDATION REPORT")
message(paste(rep("=", 70), collapse = ""))

validation <- validate_nonmem_data(nonmem_data)
print_validation_report(validation)

# ============================================================================
# Additional QC Checks
# ============================================================================

message("\n=== Additional Data Quality Checks ===")

# Check 1: Dose-concentration consistency
message("\n1. DOSE-CONCENTRATION CONSISTENCY")
dose_conc_check <- nonmem_data %>%
  filter(EVID == 0, !is.na(DV)) %>%
  left_join(dm_data %>% select(USUBJID, ARMCD), by = "USUBJID") %>%
  group_by(ARMCD) %>%
  summarise(
    N_subjects = n_distinct(ID),
    Mean_Cmax = round(max(DV), 2),
    Median_Cmax = round(median(tapply(DV, ID, max)), 2),
    .groups = "drop"
  )

print(dose_conc_check)

if (nrow(dose_conc_check) > 1) {
  # Check if Cmax increases with dose
  dose_proportional <- all(diff(dose_conc_check$Median_Cmax) > 0)
  if (dose_proportional) {
    message("✅ Cmax increases with dose (expected for dose-proportional PK)")
  } else {
    message("⚠️  Cmax does NOT increase with dose (review recommended)")
  }
}

# Check 2: Missing concentrations (BLQ)
message("\n2. BELOW LIMIT OF QUANTIFICATION (BLQ) ANALYSIS")
blq_summary <- nonmem_data %>%
  filter(EVID == 0) %>%
  group_by(ID) %>%
  summarise(
    Total_obs = n(),
    BLQ_count = sum(is.na(DV)),
    BLQ_percent = round(100 * sum(is.na(DV)) / n(), 1),
    .groups = "drop"
  )

message("BLQ by subject:")
message("  Total BLQ observations: ", sum(blq_summary$BLQ_count), 
        " / ", sum(blq_summary$Total_obs),
        " (", round(100 * sum(blq_summary$BLQ_count) / sum(blq_summary$Total_obs), 1), "%)")

# Flag subjects with >50% BLQ
high_blq <- blq_summary %>% filter(BLQ_percent > 50)
if (nrow(high_blq) > 0) {
  message("⚠️  ", nrow(high_blq), " subjects have >50% BLQ observations")
} else {
  message("✅ No subjects with excessive BLQ (>50%)")
}

# Check 3: Time point coverage
message("\n3. SAMPLING TIME POINT COVERAGE")
time_coverage <- nonmem_data %>%
  filter(EVID == 0) %>%
  group_by(TIME) %>%
  summarise(
    N_subjects = n_distinct(ID),
    N_with_data = sum(!is.na(DV)),
    Pct_coverage = round(100 * N_with_data / n_distinct(nonmem_data$ID), 1),
    .groups = "drop"
  )

print(time_coverage)

if (any(time_coverage$Pct_coverage < 80)) {
  message("⚠️  Some timepoints have <80% coverage")
} else {
  message("✅ All timepoints have ≥80% coverage")
}

# Check 4: Time ordering per subject
message("\n4. TIME ORDERING VALIDATION")
time_order_issues <- nonmem_data %>%
  group_by(ID) %>%
  arrange(ID, TIME, desc(EVID)) %>%
  mutate(time_diff = TIME - lag(TIME, default = -Inf)) %>%
  filter(time_diff < 0) %>%
  ungroup()

if (nrow(time_order_issues) > 0) {
  message("❌ ", nrow(time_order_issues), " records have time ordering issues")
  print(head(time_order_issues))
} else {
  message("✅ All records properly ordered by TIME")
}

# Check 5: Calculate basic PK parameters for QC
message("\n5. PK PARAMETER QC")
pk_params <- summarize_pk_by_subject(nonmem_data)

message("PK Parameters Summary (all subjects):")
pk_summary <- pk_params %>%
  summarise(
    N = n(),
    Cmax_mean = round(mean(Cmax, na.rm = TRUE), 2),
    Cmax_CV = round(100 * sd(Cmax, na.rm = TRUE) / mean(Cmax, na.rm = TRUE), 1),
    Tmax_median = round(median(Tmax, na.rm = TRUE), 2),
    AUC_mean = round(mean(AUC_last, na.rm = TRUE), 2)
  )

print(pk_summary)

# Check for outliers (Cmax > 3 SD from mean)
cmax_outliers <- pk_params %>%
  mutate(
    z_score = (Cmax - mean(Cmax)) / sd(Cmax),
    is_outlier = abs(z_score) > 3
  ) %>%
  filter(is_outlier)

if (nrow(cmax_outliers) > 0) {
  message("⚠️  ", nrow(cmax_outliers), " subjects have Cmax outliers (>3 SD)")
} else {
  message("✅ No Cmax outliers detected")
}

# ============================================================================
# Final QC Summary
# ============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("QC VALIDATION SUMMARY")
message(paste(rep("=", 70), collapse = ""))

if (validation$valid) {
  message("\n✅ DATASET PASSED ALL CORE VALIDATION CHECKS")
  message("\nDataset is ready for NONMEM analysis")
  message("Recommended next steps:")
  message("  1. Review BLQ handling strategy")
  message("  2. Confirm covariate definitions")
  message("  3. Prepare NONMEM control stream")
  message("  4. Run exploratory data analysis")
} else {
  message("\n❌ DATASET FAILED VALIDATION")
  message("\nPlease address the following issues before analysis:")
  for (err in validation$errors) {
    message("  - ", err)
  }
}

message("\n=== QC Report Complete ===")
