# nonmemtools 0.1.0

## Initial Release (2025-12-23)

### Features

* **SDTM to NONMEM Conversion**
  - `create_nonmem_dataset()`: Convert CDISC SDTM domains (PC, EX, DM) to NONMEM format
  - Automatic TIME calculation relative to first dose
  - Proper EVID, CMT, and MDV coding
  - Covariate integration from demographics
  - `write_nonmem_data()`: Export with NONMEM-compatible formatting

* **Data Validation Framework**
  - `validate_nonmem_data()`: Comprehensive QC checks including:
    - Required variable presence
    - TIME ordering within subjects
    - EVID validity (0, 1, 2, 3, 4)
    - AMT consistency for dosing records
    - MDV/DV relationship validation
    - Subject-level dose verification
  - `print_validation_report()`: Formatted QC report output
  - 9 distinct validation checks with error/warning categorization

* **PK Parameter Calculations**
  - `calculate_pk_parameters()`: Individual PK parameters
    - Cmax, Tmax (maximum concentration and time)
    - AUC by trapezoidal rule (AUC₀₋last)
    - Terminal half-life estimation
    - AUC₀₋∞ extrapolation
  - `summarize_pk_by_subject()`: Population-level PK summaries
  - Robust handling of missing values and BLQ data

### Documentation

* Comprehensive README with:
  - Quick start guide
  - Repository structure
  - Connection to ICON job requirements
  - Technical stack overview
  - Links to related portfolios

* Vignettes:
  - `vignette("nonmem-workflow")`: Complete SDTM → NONMEM workflow
  - `vignette("pk-analysis")`: PK parameter interpretation and visualization

* Example scripts:
  - `examples/01_basic_conversion.R`: Basic SDTM to NONMEM conversion
  - `examples/02_popPK_dataset.R`: Population PK dataset creation
  - `examples/03_qc_validation.R`: Data validation workflow

### Testing

* Unit tests with `testthat`:
  - `test-sdtm-conversion.R`: Conversion function validation
  - `test-validation.R`: QC framework testing
  - `test-pk-calculations.R`: PK parameter accuracy
* Test coverage: ~85%

### Infrastructure

* R package structure with proper DESCRIPTION and NAMESPACE
* GitHub Actions CI/CD for automated testing
* pkgdown website configuration
* MIT License

### Data

* Example SDTM datasets:
  - 25 synthetic subjects
  - Single ascending dose design (100, 300, 600 mg)
  - Rich PK sampling (0, 0.5, 1, 2, 4, 8, 12, 24h)
  - Realistic PK profiles with inter-subject variability

## Roadmap

### Version 0.2.0 (Planned)

* Integration with `NMdata` package for enhanced NONMEM workflows
* ADAM ADPC dataset creation with `admiral`
* Support for multiple dosing regimens (II, ADDL parameters)
* Shiny dashboard for interactive dataset exploration
* Additional vignettes:
  - Steady-state PK analysis
  - Covariate handling best practices
  - Regulatory submission preparation

### Version 0.3.0 (Planned)

* Population PK model diagnostics
* Integration with NONMEM output (via NMscanData)
* BLQ imputation methods
* Enhanced visualization functions
* Cross-domain SDTM integration (VS, LB for covariates)

## Acknowledgments

* Inspired by CDISC standards and FDA guidance
* Built with pharmaverse ecosystem principles
* Developed for Senior Statistical Programmer roles at ICON Strategic Solutions

---

**Target Audience**: Clinical statistical programmers, pharmacometricians, and biostatisticians working with NONMEM and CDISC standards in pharmaceutical drug development.

**Repository**: https://github.com/stiigg/r-nonmem-pkpd-portfolio

**Contact**: Christian Baghai | [LinkedIn](https://www.linkedin.com/in/christian-baghai-236399a5/)
