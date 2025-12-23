#' nonmemtools: R Tools for NONMEM PK/PD Dataset Preparation
#'
#' This package provides functions for converting CDISC SDTM data to NONMEM
#' format, validating NONMEM datasets, and calculating pharmacokinetic parameters.
#' It is designed for clinical statistical programmers and pharmacometricians
#' working with population PK/PD modeling.
#'
#' @section Main Functions:
#'
#' **Data Conversion:**
#' \itemize{
#'   \item \code{\link{create_nonmem_dataset}}: Convert SDTM (PC, EX, DM) to NONMEM format
#'   \item \code{\link{write_nonmem_data}}: Export NONMEM dataset to CSV
#' }
#'
#' **Data Validation:**
#' \itemize{
#'   \item \code{\link{validate_nonmem_data}}: Comprehensive QC checks
#'   \item \code{\link{print_validation_report}}: Formatted validation output
#' }
#'
#' **PK Calculations:**
#' \itemize{
#'   \item \code{\link{calculate_pk_parameters}}: Individual PK parameters (Cmax, AUC, t1/2)
#'   \item \code{\link{summarize_pk_by_subject}}: Population-level PK summaries
#' }
#'
#' @section Key Features:
#'
#' \itemize{
#'   \item CDISC SDTM compliance
#'   \item Proper NONMEM data structure (EVID, CMT, MDV)
#'   \item Automated TIME calculation relative to first dose
#'   \item Comprehensive data validation (9 QC checks)
#'   \item PK parameter calculations with trapezoidal AUC
#'   \item Integration-ready for NMdata and admiral workflows
#' }
#'
#' @section Example Workflow:
#'
#' \preformatted{
#' # Load SDTM data
#' pc <- read.csv("sdtm_pc.csv")
#' ex <- read.csv("sdtm_ex.csv")
#' dm <- read.csv("sdtm_dm.csv")
#'
#' # Convert to NONMEM format
#' nonmem_data <- create_nonmem_dataset(
#'   pc_data = pc,
#'   ex_data = ex,
#'   dm_data = dm,
#'   study_id = "STUDY001"
#' )
#'
#' # Validate dataset
#' qc_results <- validate_nonmem_data(nonmem_data)
#' print_validation_report(qc_results)
#'
#' # Export for NONMEM
#' write_nonmem_data(nonmem_data, "pk_data.csv")
#'
#' # Calculate PK parameters
#' pk_summary <- summarize_pk_by_subject(nonmem_data)
#' }
#'
#' @section Vignettes:
#'
#' \itemize{
#'   \item \code{vignette("nonmem-workflow")}: Complete SDTM to NONMEM workflow
#'   \item \code{vignette("pk-analysis")}: PK parameter interpretation
#' }
#'
#' @section Target Audience:
#'
#' This package is designed for:
#' \itemize{
#'   \item Clinical Statistical Programmers
#'   \item Pharmacometricians
#'   \item Biostatisticians
#'   \item PK/PD Scientists
#' }
#'
#' working with NONMEM and CDISC standards in pharmaceutical drug development.
#'
#' @author Christian Baghai \email{christian.baghai@@outlook.fr}
#'
#' @keywords internal
#' @docType package
#' @name nonmemtools-package
#' @aliases nonmemtools
#'
#' @importFrom dplyr %>% filter select mutate group_by ungroup arrange
#'   summarise left_join bind_rows any_of slice desc n
#' @importFrom readr write_csv
"_PACKAGE"
