#' Convert SDTM PC, EX, DM Data to NONMEM Format
#'
#' This function combines SDTM pharmacokinetic concentration (PC),
#' exposure/dosing (EX), and demographics (DM) data into a NONMEM-ready dataset.
#'
#' @param pc_data Data frame containing SDTM PC domain (plasma concentrations)
#' @param ex_data Data frame containing SDTM EX domain (dosing records)
#' @param dm_data Data frame containing SDTM DM domain (demographics)
#' @param study_id Character string for study identifier
#' @param base_time Reference time for TIME calculation (default: first dose)
#'
#' @return Data frame in NONMEM format with columns:
#'   - ID: Subject identifier
#'   - TIME: Time since first dose (hours)
#'   - AMT: Dose amount (for dosing records)
#'   - DV: Dependent variable (concentration)
#'   - EVID: Event ID (0=observation, 1=dose)
#'   - CMT: Compartment (1=dosing, 2=observation)
#'   - MDV: Missing DV indicator
#'   - Plus covariates: AGE, SEX, WEIGHT, etc.
#'
#' @examples
#' \dontrun{
#' nonmem_data <- create_nonmem_dataset(
#'   pc_data = sdtm_pc,
#'   ex_data = sdtm_ex,
#'   dm_data = sdtm_dm,
#'   study_id = "STUDY001"
#' )
#' }
#'
#' @export
create_nonmem_dataset <- function(pc_data, ex_data, dm_data, 
                                   study_id = "STUDY", 
                                   base_time = "first_dose") {
  
  # Input validation
  stopifnot(
    "pc_data must be a data frame" = is.data.frame(pc_data),
    "ex_data must be a data frame" = is.data.frame(ex_data),
    "dm_data must be a data frame" = is.data.frame(dm_data)
  )
  
  # Required SDTM variables
  required_pc <- c("USUBJID", "PCDTC", "PCSTRESN", "PCTPTNUM")
  required_ex <- c("USUBJID", "EXSTDTC", "EXDOSE")
  required_dm <- c("USUBJID", "AGE", "SEX")
  
  # Check required variables exist
  stopifnot(
    "PC domain missing required variables" = all(required_pc %in% names(pc_data)),
    "EX domain missing required variables" = all(required_ex %in% names(ex_data)),
    "DM domain missing required variables" = all(required_dm %in% names(dm_data))
  )
  
  # Process dosing records (EVID=1)
  dose_records <- ex_data %>%
    dplyr::select(USUBJID, EXSTDTC, EXDOSE) %>%
    dplyr::mutate(
      EVID = 1,
      CMT = 1,
      AMT = EXDOSE,
      DV = NA_real_,
      MDV = 1,
      DATETIME = as.POSIXct(EXSTDTC, format = "%Y-%m-%dT%H:%M")
    )
  
  # Process concentration records (EVID=0)
  conc_records <- pc_data %>%
    dplyr::select(USUBJID, PCDTC, PCSTRESN) %>%
    dplyr::mutate(
      EVID = 0,
      CMT = 2,
      AMT = 0,
      DV = PCSTRESN,
      MDV = ifelse(is.na(PCSTRESN), 1, 0),
      DATETIME = as.POSIXct(PCDTC, format = "%Y-%m-%dT%H:%M")
    )
  
  # Combine dosing and concentration records
  combined_data <- dplyr::bind_rows(dose_records, conc_records)
  
  # Calculate TIME relative to first dose per subject
  combined_data <- combined_data %>%
    dplyr::group_by(USUBJID) %>%
    dplyr::arrange(DATETIME) %>%
    dplyr::mutate(
      FIRST_DOSE_TIME = min(DATETIME[EVID == 1]),
      TIME = as.numeric(difftime(DATETIME, FIRST_DOSE_TIME, units = "hours"))
    ) %>%
    dplyr::ungroup()
  
  # Merge demographics (covariates)
  nonmem_data <- combined_data %>%
    dplyr::left_join(dm_data, by = "USUBJID") %>%
    dplyr::mutate(
      ID = as.integer(factor(USUBJID)),
      STUDY = study_id,
      SEXN = ifelse(SEX == "M", 1, 2)
    ) %>%
    dplyr::select(
      ID, TIME, AMT, DV, EVID, CMT, MDV,
      AGE, SEXN, 
      dplyr::any_of(c("WEIGHT", "HEIGHT", "RACE", "ETHNIC")),
      USUBJID, STUDY
    ) %>%
    dplyr::arrange(ID, TIME, dplyr::desc(EVID))
  
  # Add row identifier
  nonmem_data$ROW <- seq_len(nrow(nonmem_data))
  
  # Return NONMEM dataset
  return(nonmem_data)
}


#' Write NONMEM Dataset to CSV
#'
#' Exports NONMEM dataset with proper formatting for NONMEM software
#'
#' @param data NONMEM dataset
#' @param file Output file path
#' @param na_string String to represent missing values (default: ".")
#'
#' @export
write_nonmem_data <- function(data, file, na_string = ".") {
  readr::write_csv(
    data, 
    file, 
    na = na_string,
    quote = "none"
  )
  message("NONMEM dataset written to: ", file)
  message("Rows: ", nrow(data))
  message("Subjects: ", length(unique(data$ID)))
}
