# R Programming Portfolio: NONMEM PK/PD Dataset Preparation

[![R Version](https://img.shields.io/badge/R-%3E%3D4.3.0-blue)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

This portfolio demonstrates **R programming expertise for pharmacometrics**, specifically targeting:
- NONMEM PK/PD dataset preparation from SDTM/ADAM sources
- Quality control and validation of pharmacometric datasets
- Custom R package development for standardized workflows
- Integration with CDISC clinical trial data standards

**Target Role**: Senior Statistical Programmer I (Pharmacometrics) at ICON Strategic Solutions

---

## Key Skills Demonstrated

### 1. NONMEM Dataset Preparation
- Converting SDTM (PC, EX, DM domains) to NONMEM format
- Handling concentration-time data and dosing records
- Creating population PK (PopPK) analysis datasets
- Data validation and quality checks

### 2. R Programming Proficiency
- Advanced data manipulation with `dplyr` and `data.table`
- Custom function development for reusable workflows
- Package development with roxygen2 documentation
- Unit testing with `testthat`

### 3. PK/PD Knowledge
- Pharmacokinetic parameter calculations (Cmax, AUC, Tmax)
- Concentration-time profile analysis
- Dose-exposure-response relationships
- Understanding of NONMEM input data requirements

### 4. CDISC Standards Integration
- SDTM domain expertise (PC, EX, DM, VS, LB)
- ADAM dataset creation with `admiral` package
- Controlled terminology implementation
- Metadata-driven programming

---

## Repository Structure

```
r-nonmem-pkpd-portfolio/
├── R/                          # Core R functions
│   ├── sdtm_to_nonmem.R       # SDTM → NONMEM conversion
│   ├── pk_calculations.R       # PK parameter calculations
│   ├── data_validation.R       # QC checks
│   └── utils.R                 # Helper functions
├── data-raw/                   # Example input data
│   ├── sdtm_pc.csv            # Plasma concentration data
│   ├── sdtm_ex.csv            # Exposure/dosing data
│   └── sdtm_dm.csv            # Demographics
├── data/                       # Processed/example outputs
│   └── nonmem_pk_dataset.csv
├── examples/                   # Usage demonstrations
│   ├── 01_basic_conversion.R
│   ├── 02_popPK_dataset.R
│   └── 03_qc_validation.R
├── tests/                      # Unit tests
│   └── testthat/
├── vignettes/                  # Detailed tutorials
│   ├── nonmem_workflow.Rmd
│   └── pk_analysis.Rmd
├── pkgdown/                    # Package website
├── DESCRIPTION                 # Package metadata
├── NAMESPACE                   # Package exports
└── README.md                   # This file
```

---

## Quick Start

### Installation

```r
# Install from GitHub
# install.packages("remotes")
remotes::install_github("stiigg/r-nonmem-pkpd-portfolio")

# Load required packages
library(dplyr)
library(tidyr)
library(admiral)
library(NMdata)  # For NONMEM data handling
```

### Basic Usage

```r
# Load example SDTM data
pc <- read.csv("data-raw/sdtm_pc.csv")  # Plasma concentration
ex <- read.csv("data-raw/sdtm_ex.csv")  # Dosing
dm <- read.csv("data-raw/sdtm_dm.csv")  # Demographics

# Convert to NONMEM format
nonmem_data <- create_nonmem_dataset(
  pc_data = pc,
  ex_data = ex,
  dm_data = dm,
  study_id = "ABC123"
)

# Run quality checks
qc_results <- validate_nonmem_data(nonmem_data)

# Export for NONMEM
write_nonmem_data(nonmem_data, "output/pk_data.csv")
```

---

## Featured Examples

### Example 1: SDTM to NONMEM Conversion
Demonstrates conversion of CDISC SDTM domains (PC, EX, DM) into NONMEM-ready format with proper TIME, AMT, DV, and EVID coding.

[View Code](examples/01_basic_conversion.R)

### Example 2: Population PK Dataset
Creates a complete PopPK analysis dataset with covariate handling, baseline calculations, and concentration-time data.

[View Code](examples/02_popPK_dataset.R)

### Example 3: Data Validation & QC
Implements comprehensive quality checks including:
- Missing value detection
- Time ordering validation
- Dose-concentration alignment
- NONMEM data requirements verification

[View Code](examples/03_qc_validation.R)

---

## Technical Stack

| Component | Tools |
|-----------|-------|
| **Data Manipulation** | dplyr, tidyr, data.table |
| **CDISC Standards** | admiral, metacore, pharmaversesdtm |
| **NONMEM Integration** | NMdata, PMXTools |
| **PK/PD Analysis** | NonCompart, PKNCA |
| **Testing** | testthat, covr |
| **Documentation** | roxygen2, pkgdown, rmarkdown |
| **Version Control** | GitHub Actions CI/CD |

---

## Learning Resources Used

This portfolio incorporates best practices from:
- NONMEM tutorials and documentation
- FDA CDISC submission guidelines
- pharmaverse community standards
- Page-meeting.org pharmacometric resources
- Industry white papers on PopPK analysis

---

## Connection to ICON Job Requirements

This repository directly addresses the **Senior Statistical Programmer I** role at ICON:

✅ **Strong working knowledge of R software**  
- Custom functions, package development, advanced tidyverse usage

✅ **NONMEM PK/PD dataset preparation**  
- Complete SDTM → NONMEM conversion workflows

✅ **Knowledge of SDTM, ADAM, and controlled terminology**  
- Integration with admiral and pharmaverse ecosystem

✅ **QC of existing R packages**  
- Unit tests, validation frameworks, test suites

✅ **Standardization efforts for NONMEM file creation**  
- Reusable functions, metadata-driven approach, documentation

✅ **Interest in PK/PD and clinical trial concepts**  
- Practical examples with real-world scenarios

---

## Future Enhancements

- [ ] Add Shiny dashboard for interactive NONMEM dataset exploration
- [ ] Implement additional PK/PD models (PKPD, compartmental)
- [ ] Create vignettes for iRECIST oncology integration
- [ ] Add GitHub Actions for automated testing
- [ ] Develop pkgdown website for professional documentation
- [ ] Include validation documentation (IQ/OQ/PQ protocols)

---

## Contact

**Christian Baghai**  
📧 [Your Email]  
🔗 [LinkedIn](https://www.linkedin.com/in/christian-baghai-236399a5/)  
💼 Portfolio: [github.com/stiigg](https://github.com/stiigg)

**Other Relevant Repositories:**
- [SAS-R Hybrid Clinical Pipeline](https://github.com/stiigg/sas-r-hybrid-clinical-pipeline) - SDTM/ADAM with SAS & R
- [ADaM in R Starter](https://github.com/stiigg/adam-in-r-starter) - Clinical programming scaffold
- [Clinical Programming Portfolio](https://github.com/stiigg/clinical-programming-portfolio-sas-cdisc) - SAS expertise

---

## License

MIT License - See [LICENSE](LICENSE) file for details

---

*This portfolio is actively maintained and demonstrates production-ready code for pharmaceutical clinical trials and regulatory submissions.*
