#' Calculate Basic PK Parameters
#'
#' Computes standard pharmacokinetic parameters from concentration-time data
#'
#' @param time Numeric vector of time points (hours)
#' @param conc Numeric vector of concentrations (same units as dose)
#' @param dose Administered dose amount
#'
#' @return List containing:
#'   - Cmax: Maximum observed concentration
#'   - Tmax: Time of maximum concentration
#'   - AUC_last: Area under curve to last measurable concentration
#'   - AUC_inf: Area under curve extrapolated to infinity (if calculable)
#'   - t_half: Terminal elimination half-life
#'
#' @examples
#' \dontrun{
#' pk_params <- calculate_pk_parameters(
#'   time = c(0, 1, 2, 4, 8, 12, 24),
#'   conc = c(0, 15, 22, 18, 10, 5, 1),
#'   dose = 100
#' )
#' }
#'
#' @export
calculate_pk_parameters <- function(time, conc, dose) {
  
  # Remove missing values
  valid_idx <- !is.na(time) & !is.na(conc) & conc > 0
  time_clean <- time[valid_idx]
  conc_clean <- conc[valid_idx]
  
  if (length(time_clean) < 3) {
    warning("Insufficient data points for PK calculations")
    return(NULL)
  }
  
  # Cmax and Tmax
  cmax <- max(conc_clean)
  tmax <- time_clean[which.max(conc_clean)]
  
  # AUC using trapezoidal rule
  auc_last <- 0
  for (i in 2:length(time_clean)) {
    dt <- time_clean[i] - time_clean[i-1]
    avg_conc <- (conc_clean[i] + conc_clean[i-1]) / 2
    auc_last <- auc_last + (dt * avg_conc)
  }
  
  # Estimate terminal half-life (simplified - uses last 3 points)
  if (length(time_clean) >= 3) {
    last_3_idx <- (length(time_clean) - 2):length(time_clean)
    log_conc <- log(conc_clean[last_3_idx])
    time_terminal <- time_clean[last_3_idx]
    
    # Linear regression on log-concentration
    fit <- lm(log_conc ~ time_terminal)
    lambda_z <- -coef(fit)[2]  # Elimination rate constant
    t_half <- log(2) / lambda_z
    
    # Extrapolate AUC to infinity
    c_last <- conc_clean[length(conc_clean)]
    auc_inf <- auc_last + (c_last / lambda_z)
  } else {
    t_half <- NA
    auc_inf <- NA
  }
  
  # Return PK parameters
  list(
    Cmax = cmax,
    Tmax = tmax,
    AUC_last = auc_last,
    AUC_inf = auc_inf,
    t_half = t_half,
    dose = dose
  )
}


#' Summarize PK Parameters by Subject
#'
#' Calculates PK parameters for each subject in a NONMEM dataset
#'
#' @param nonmem_data NONMEM format dataset
#'
#' @return Data frame with one row per subject containing PK parameters
#'
#' @export
summarize_pk_by_subject <- function(nonmem_data) {
  
  # Extract observation records only
  obs_data <- nonmem_data %>%
    dplyr::filter(EVID == 0, !is.na(DV), DV > 0)
  
  # Get first dose per subject
  dose_data <- nonmem_data %>%
    dplyr::filter(EVID == 1) %>%
    dplyr::group_by(ID) %>%
    dplyr::slice(1) %>%
    dplyr::select(ID, AMT)
  
  # Calculate PK parameters per subject
  pk_summary <- obs_data %>%
    dplyr::group_by(ID) %>%
    dplyr::summarise(
      n_obs = dplyr::n(),
      Cmax = max(DV, na.rm = TRUE),
      Tmax = TIME[which.max(DV)],
      AUC_last = calculate_auc_trap(TIME, DV),
      .groups = "drop"
    ) %>%
    dplyr::left_join(dose_data, by = "ID")
  
  return(pk_summary)
}


# Helper: AUC by trapezoidal rule
calculate_auc_trap <- function(time, conc) {
  if (length(time) < 2) return(NA)
  
  auc <- 0
  for (i in 2:length(time)) {
    dt <- time[i] - time[i-1]
    avg_conc <- (conc[i] + conc[i-1]) / 2
    auc <- auc + (dt * avg_conc)
  }
  return(auc)
}
