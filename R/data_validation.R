#' Validate NONMEM Dataset
#'
#' Performs comprehensive quality checks on NONMEM datasets to ensure
#' data integrity and compliance with NONMEM requirements.
#'
#' @param data NONMEM dataset to validate
#'
#' @return List containing:
#'   - valid: Logical indicating if all checks passed
#'   - errors: Character vector of error messages
#'   - warnings: Character vector of warning messages
#'   - summary: Data frame with validation statistics
#'
#' @examples
#' \dontrun{
#' qc_results <- validate_nonmem_data(nonmem_dataset)
#' if (!qc_results$valid) {
#'   print(qc_results$errors)
#' }
#' }
#'
#' @export
validate_nonmem_data <- function(data) {
  
  errors <- character()
  warnings <- character()
  
  # Check 1: Required variables present
  required_vars <- c("ID", "TIME", "DV", "AMT", "EVID", "CMT", "MDV")
  missing_vars <- setdiff(required_vars, names(data))
  
  if (length(missing_vars) > 0) {
    errors <- c(errors, paste0(
      "Missing required variables: ", 
      paste(missing_vars, collapse = ", ")
    ))
  }
  
  # Check 2: ID must be numeric
  if (!is.numeric(data$ID)) {
    errors <- c(errors, "ID must be numeric")
  }
  
  # Check 3: TIME must be non-negative
  if (any(data$TIME < 0, na.rm = TRUE)) {
    errors <- c(errors, "TIME contains negative values")
  }
  
  # Check 4: EVID values must be valid (0, 1, 2, 3, 4)
  valid_evid <- c(0, 1, 2, 3, 4)
  if (!all(data$EVID %in% valid_evid)) {
    errors <- c(errors, "EVID contains invalid values (must be 0, 1, 2, 3, or 4)")
  }
  
  # Check 5: Dosing records (EVID=1) must have AMT > 0
  dose_records <- data[data$EVID == 1, ]
  if (nrow(dose_records) > 0) {
    if (any(dose_records$AMT <= 0, na.rm = TRUE)) {
      errors <- c(errors, "Dosing records (EVID=1) must have AMT > 0")
    }
  }
  
  # Check 6: Observation records (EVID=0) should have AMT=0
  obs_records <- data[data$EVID == 0, ]
  if (nrow(obs_records) > 0) {
    if (any(obs_records$AMT != 0, na.rm = TRUE)) {
      warnings <- c(warnings, "Observation records (EVID=0) have non-zero AMT")
    }
  }
  
  # Check 7: MDV consistency with DV missingness
  if (any(is.na(data$DV) & data$MDV == 0)) {
    errors <- c(errors, "Missing DV values but MDV=0")
  }
  
  # Check 8: Time ordering within subjects
  time_check <- data %>%
    dplyr::group_by(ID) %>%
    dplyr::summarise(is_ordered = all(TIME == cummax(TIME))) %>%
    dplyr::filter(!is_ordered)
  
  if (nrow(time_check) > 0) {
    warnings <- c(warnings, sprintf(
      "TIME not monotonically increasing for %d subjects",
      nrow(time_check)
    ))
  }
  
  # Check 9: At least one dosing record per subject
  dose_count <- data %>%
    dplyr::group_by(ID) %>%
    dplyr::summarise(n_doses = sum(EVID == 1)) %>%
    dplyr::filter(n_doses == 0)
  
  if (nrow(dose_count) > 0) {
    warnings <- c(warnings, sprintf(
      "%d subjects have no dosing records",
      nrow(dose_count)
    ))
  }
  
  # Summary statistics
  summary_stats <- data.frame(
    metric = c(
      "Total records",
      "Unique subjects",
      "Dosing records",
      "Observation records",
      "Missing DV values",
      "Time range (hours)"
    ),
    value = c(
      nrow(data),
      length(unique(data$ID)),
      sum(data$EVID == 1),
      sum(data$EVID == 0),
      sum(is.na(data$DV)),
      sprintf("%.2f - %.2f", min(data$TIME, na.rm = TRUE), max(data$TIME, na.rm = TRUE))
    )
  )
  
  # Return validation results
  list(
    valid = length(errors) == 0,
    errors = errors,
    warnings = warnings,
    summary = summary_stats
  )
}


#' Generate Validation Report
#'
#' Creates a formatted validation report for NONMEM dataset QC
#'
#' @param validation_results Output from validate_nonmem_data()
#'
#' @export
print_validation_report <- function(validation_results) {
  cat("\n=== NONMEM Dataset Validation Report ===\n\n")
  
  if (validation_results$valid) {
    cat("\u2705 VALIDATION PASSED\n\n")
  } else {
    cat("\u274c VALIDATION FAILED\n\n")
  }
  
  # Errors
  if (length(validation_results$errors) > 0) {
    cat("ERRORS (must fix):\n")
    for (err in validation_results$errors) {
      cat("  - ", err, "\n")
    }
    cat("\n")
  }
  
  # Warnings
  if (length(validation_results$warnings) > 0) {
    cat("WARNINGS (review recommended):\n")
    for (warn in validation_results$warnings) {
      cat("  - ", warn, "\n")
    }
    cat("\n")
  }
  
  # Summary
  cat("DATASET SUMMARY:\n")
  print(validation_results$summary, row.names = FALSE)
  cat("\n")
}
