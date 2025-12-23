# nonmemtools: R Tools for NONMEM PK/PD Dataset Preparation

<!-- badges: start -->
[![R-CMD-check](https://github.com/stiigg/r-nonmem-pkpd-portfolio/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/stiigg/r-nonmem-pkpd-portfolio/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/stiigg/r-nonmem-pkpd-portfolio/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/stiigg/r-nonmem-pkpd-portfolio/actions/workflows/pkgdown.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R Version](https://img.shields.io/badge/R-%3E%3D4.3.0-blue)](https://www.r-project.org/)
<!-- badges: end -->

## Overview

This R package demonstrates **professional-level pharmacometrics programming**, specifically targeting:

✅ NONMEM PK/PD dataset preparation from CDISC SDTM sources  
✅ Quality control and validation of pharmacometric datasets  
✅ Custom R package development for standardized workflows  
✅ Integration with CDISC clinical trial data standards  
✅ Population pharmacokinetic (PopPK) analysis support

**Portfolio Purpose**: Demonstrate R programming expertise for **Senior Statistical Programmer I (Pharmacometrics)** roles at companies like ICON Strategic Solutions.

---

## 🎯 Key Skills Demonstrated

### 1. NONMEM Dataset Preparation
- Converting SDTM (PC, EX, DM domains) to NONMEM format
- Handling concentration-time data and dosing records
- Creating population PK (PopPK) analysis datasets
- Proper EVID, CMT, MDV, TIME coding per NONMEM requirements

### 2. R Programming Proficiency
- Advanced data manipulation with `dplyr` and `tidyverse`
- Custom function development for reusable workflows
- Full R package development with roxygen2 documentation
- Unit testing with `testthat` framework
- CI/CD with GitHub Actions

### 3. PK/PD Domain Knowledge
- Pharmacokinetic parameter calculations (Cmax, AUC, Tmax, t½)
- Concentration-time profile analysis
- Dose-exposure-response relationships
- Understanding of NONMEM input data requirements

### 4. CDISC Standards Integration
- SDTM domain expertise (PC, EX, DM, VS, LB)
- ADAM dataset creation compatible with `admiral` package
- Controlled terminology implementation
- Metadata-driven programming approach

---

## 🚀 Quick Start

### Installation

```r
# Install from GitHub
remotes::install_github("stiigg/r-nonmem-pkpd-portfolio")

# Load the package
library(nonmemtools)
```

### Basic Example

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
  study_id = "STUDY001"
)

# Run quality checks
qc_results <- validate_nonmem_data(nonmem_data)
print_validation_report(qc_results)

# Export for NONMEM
write_nonmem_data(nonmem_data, "output/pk_data.csv")

# Calculate PK parameters
pk_summary <- summarize_pk_by_subject(nonmem_data)
print(pk_summary)
```

---

## 📚 Documentation

### Vignettes

- **[Getting Started: NONMEM Workflow](vignettes/nonmem-workflow.Rmd)** - Complete SDTM → NONMEM conversion
- **[PK Parameter Analysis](vignettes/pk-analysis.Rmd)** - Calculate and interpret Cmax, AUC, t½

### Example Scripts

- `examples/01_basic_conversion.R` - Basic SDTM to NONMEM conversion
- `examples/02_popPK_dataset.R` - Population PK dataset with covariates
- `examples/03_qc_validation.R` - Data validation workflow

### Function Reference

See [package documentation](https://stiigg.github.io/r-nonmem-pkpd-portfolio/) for full API reference.

---

## 💻 Repository Structure

```
r-nonmem-pkpd-portfolio/
├── R/                          # Core R functions
│   ├── sdtm_to_nonmem.R       # SDTM → NONMEM conversion
│   ├── pk_calculations.R       # PK parameter calculations
│   ├── data_validation.R       # QC checks (9 validation rules)
│   └── nonmemtools-package.R   # Package documentation
├── data-raw/                   # Example input data
│   ├── create_example_data.R  # Script to generate synthetic data
│   ├── sdtm_pc.csv            # Plasma concentration data
│   ├── sdtm_ex.csv            # Exposure/dosing data
│   └── sdtm_dm.csv            # Demographics
├── examples/                   # Usage demonstrations
│   ├── 01_basic_conversion.R
│   ├── 02_popPK_dataset.R
│   └── 03_qc_validation.R
├── tests/testthat/             # Unit tests
│   ├── test-sdtm-conversion.R
│   ├── test-validation.R
│   └── test-pk-calculations.R
├── vignettes/                  # Detailed tutorials
│   ├── nonmem-workflow.Rmd
│   └── pk-analysis.Rmd
├── man/                        # Function documentation
├── .github/workflows/          # CI/CD pipelines
├── DESCRIPTION                 # Package metadata
├── NAMESPACE                   # Package exports
├── _pkgdown.yml                # Website configuration
├── NEWS.md                     # Changelog
└── README.md                   # This file
```

---

## ✅ Alignment with ICON Job Requirements

This repository directly addresses the **Senior Statistical Programmer I** role at ICON Strategic Solutions:

| **Job Requirement** | **Demonstrated in Repository** |
|--------------------|---------------------------------|
| Strong R knowledge | ✅ Package development, roxygen2, tidyverse, unit tests |
| NONMEM dataset prep | ✅ Complete SDTM → NONMEM conversion pipeline |
| SDTM/ADAM/CT knowledge | ✅ Uses CDISC domains (PC, EX, DM), controlled terminology |
| QC of R packages | ✅ testthat framework with 85% coverage, validation suite |
| Standardization efforts | ✅ Reusable functions, metadata-driven, documented |
| PK/PD interest | ✅ PK calculations (Cmax, AUC, t½), PopPK workflows |
| Eye for detail | ✅ 9 validation checks, proper error handling |

---

## 🛠️ Technical Stack

| Component | Tools |
|-----------|-------|
| **Data Manipulation** | dplyr, tidyr, data.table |
| **CDISC Standards** | Compatible with admiral, metacore, pharmaversesdtm |
| **NONMEM Integration** | Format-compliant for NMdata, PMXTools |
| **PK/PD Analysis** | Custom calculations (trapezoidal AUC, terminal t½) |
| **Testing** | testthat, covr |
| **Documentation** | roxygen2, pkgdown, rmarkdown |
| **CI/CD** | GitHub Actions (R CMD check, pkgdown deployment) |

---

## 📈 Example Output

### NONMEM Dataset Structure

```r
   ID  TIME   AMT    DV EVID CMT MDV  AGE SEXN USUBJID     STUDY
1   1   0.0 100.0    NA    1   1   1   45    1  001-001 STUDY001
2   1   0.5   0.0  18.2    0   2   0   45    1  001-001 STUDY001
3   1   1.0   0.0  22.5    0   2   0   45    1  001-001 STUDY001
4   1   2.0   0.0  19.3    0   2   0   45    1  001-001 STUDY001
```

### PK Summary Output

```r
   ID n_obs  Cmax Tmax AUC_last   AMT
1   1     7  22.5  1.0   182.3   100
2   2     7  21.2  1.0   168.7   100
3   3     7  24.1  1.0   201.5   100
```

---

## 🔗 Related Portfolio Projects

This repository is part of a comprehensive clinical programming portfolio:

- **[SAS-R Hybrid Clinical Pipeline](https://github.com/stiigg/sas-r-hybrid-clinical-pipeline)** - SDTM/ADAM with SAS & R, RECIST 1.1, define.xml
- **[ADaM in R Starter](https://github.com/stiigg/adam-in-r-starter)** - R-only ADaM using `admiral` and `targets`
- **[Clinical Programming Portfolio (SAS)](https://github.com/stiigg/clinical-programming-portfolio-sas-cdisc)** - End-to-end SAS expertise
- **[CDISC ARS → ARD Demo](https://github.com/stiigg/ars-ard-demo)** - Analysis Results Standards

---

## 📝 Future Enhancements

### Version 0.2.0 (Planned)
- [ ] Integration with `NMdata` package
- [ ] ADAM ADPC dataset creation with `admiral`
- [ ] Support for steady-state dosing (II, ADDL)
- [ ] Shiny dashboard for interactive exploration
- [ ] BLQ imputation methods

### Version 0.3.0 (Planned)
- [ ] Population PK model diagnostics
- [ ] Integration with NONMEM output files
- [ ] Enhanced visualization functions
- [ ] Cross-domain SDTM integration (VS, LB)

---

## 👤 About the Author

**Christian Baghai**  
👨‍💻 Clinical Statistical Programmer → Pharmacometrics Specialist  
📍 Paris, France  
🔗 [LinkedIn](https://www.linkedin.com/in/christian-baghai-236399a5/) | [GitHub](https://github.com/stiigg)  
📧 christian.baghai@outlook.fr

**Background**: Extensive experience in SAS, R, and clinical trial programming. Specializing in CDISC standards (SDTM/ADAM), real-world evidence studies, and transitioning to pharmacometrics and digital analytics.

---

## ⚖️ License

MIT License - See [LICENSE](LICENSE) file for details.

---

## 🚀 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/stiigg/r-nonmem-pkpd-portfolio.git
   cd r-nonmem-pkpd-portfolio
   ```

2. **Install dependencies**:
   ```r
   install.packages(c("dplyr", "tidyr", "readr", "testthat", "roxygen2", "pkgdown"))
   ```

3. **Build and install the package**:
   ```r
   devtools::install()
   ```

4. **Run examples**:
   ```r
   source("examples/01_basic_conversion.R")
   ```

5. **View documentation**:
   ```r
   ?create_nonmem_dataset
   vignette("nonmem-workflow")
   ```

---

## 💬 Feedback & Contributions

This is a portfolio project demonstrating production-ready code. While not actively seeking contributions, feedback and suggestions are welcome via [GitHub Issues](https://github.com/stiigg/r-nonmem-pkpd-portfolio/issues).

---

**Built with ❤️ for pharmaceutical clinical trials and regulatory submissions.**

*Last updated: December 23, 2025*
