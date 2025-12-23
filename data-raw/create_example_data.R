#' Generate Synthetic SDTM Data for NONMEM Portfolio
#'
#' Creates realistic pharmacokinetic datasets following CDISC SDTM standards
#' Simulates a Phase 1 single ascending dose study with IV administration
#'
#' Study Design:
#' - 25 subjects (adults)
#' - 3 dose levels: 100mg, 300mg, 600mg
#' - Rich PK sampling: Pre-dose, 0.5, 1, 2, 4, 8, 12, 24 hours
#' - One-compartment PK model with typical parameters

library(dplyr)
library(tidyr)

set.seed(42)  # Reproducibility

# Study parameters
n_subjects <- 25
dose_levels <- c(100, 300, 600)  # mg
subjects_per_dose <- c(8, 8, 9)
sampling_times <- c(0, 0.5, 1, 2, 4, 8, 12, 24)  # hours post-dose

# Population PK parameters (one-compartment IV model)
# Typical values for small molecule drug
pop_params <- list(
  CL = 10,      # Clearance (L/h) - population mean
  V = 50,       # Volume of distribution (L) - population mean
  CV_CL = 0.30, # 30% inter-individual variability on CL
  CV_V = 0.25,  # 25% inter-individual variability on V
  SD_RES = 0.15 # 15% residual error (proportional)
)

# ============================================================================
# 1. DEMOGRAPHICS (DM Domain)
# ============================================================================

usually_ids <- sprintf("STUDY001-%03d", 1:n_subjects)

dm <- data.frame(
  STUDYID = "STUDY001",
  DOMAIN = "DM",
  USUBJID = usually_ids,
  SUBJID = sprintf("%03d", 1:n_subjects),
  AGE = round(rnorm(n_subjects, mean = 35, sd = 10)),
  AGEU = "YEARS",
  SEX = sample(c("M", "F"), n_subjects, replace = TRUE, prob = c(0.6, 0.4)),
  RACE = sample(c("WHITE", "BLACK OR AFRICAN AMERICAN", "ASIAN"), 
                n_subjects, replace = TRUE, prob = c(0.7, 0.2, 0.1)),
  ETHNIC = "NOT HISPANIC OR LATINO",
  ARMCD = rep(c("100MG", "300MG", "600MG"), subjects_per_dose),
  ARM = rep(c("100 mg IV", "300 mg IV", "600 mg IV"), subjects_per_dose),
  COUNTRY = "USA"
)

# Add body weight (correlated with sex)
dm$WEIGHT <- ifelse(dm$SEX == "M", 
                    rnorm(n_subjects, 80, 12),  # Male: 80 kg ± 12
                    rnorm(n_subjects, 65, 10))  # Female: 65 kg ± 10
dm$WEIGHT <- round(dm$WEIGHT, 1)

# Add height
dm$HEIGHT <- ifelse(dm$SEX == "M",
                    rnorm(n_subjects, 175, 8),   # Male: 175 cm
                    rnorm(n_subjects, 165, 7))   # Female: 165 cm
dm$HEIGHT <- round(dm$HEIGHT, 1)

# Calculate BMI
dm$BMI <- round(dm$WEIGHT / ((dm$HEIGHT/100)^2), 1)

# ============================================================================
# 2. EXPOSURE/DOSING (EX Domain)
# ============================================================================

# Dosing occurred on Day 1 at 08:00
dose_datetime <- as.POSIXct("2024-01-15 08:00:00")

ex <- dm %>%
  select(STUDYID, USUBJID, SUBJID, ARMCD) %>%
  mutate(
    DOMAIN = "EX",
    EXSEQ = 1,
    EXTRT = case_when(
      ARMCD == "100MG" ~ "Drug X 100 mg",
      ARMCD == "300MG" ~ "Drug X 300 mg",
      ARMCD == "600MG" ~ "Drug X 600 mg"
    ),
    EXDOSE = as.numeric(gsub("MG", "", ARMCD)),
    EXDOSU = "mg",
    EXDOSFRM = "SOLUTION FOR INJECTION",
    EXROUTE = "INTRAVENOUS",
    EXSTDTC = format(dose_datetime, "%Y-%m-%dT%H:%M"),
    EXENDTC = format(dose_datetime + 300, "%Y-%m-%dT%H:%M"),  # 5-min infusion
    VISIT = "DAY 1",
    VISITNUM = 1,
    EXDOSFRQ = "ONCE"
  ) %>%
  select(-ARMCD)

# ============================================================================
# 3. PHARMACOKINETIC CONCENTRATIONS (PC Domain)
# ============================================================================

# Function to simulate PK concentrations (one-compartment IV bolus)
simulate_pk <- function(dose, CL, V, times, sd_res = 0.15) {
  # C(t) = (Dose/V) * exp(-CL/V * t)
  ke <- CL / V  # Elimination rate constant
  C0 <- dose / V  # Initial concentration
  
  concentrations <- C0 * exp(-ke * times)
  
  # Add proportional residual error
  concentrations <- concentrations * exp(rnorm(length(times), 0, sd_res))
  
  # Set LLOQ = 0.1 ng/mL
  concentrations[concentrations < 0.1] <- NA
  
  return(concentrations)
}

# Generate PC records for all subjects
pc_list <- list()

for (i in 1:n_subjects) {
  # Get subject info
  subj_id <- dm$USUBJID[i]
  dose <- as.numeric(gsub("MG", "", dm$ARMCD[i]))
  
  # Simulate individual PK parameters with inter-individual variability
  CL_i <- pop_params$CL * exp(rnorm(1, 0, pop_params$CV_CL))
  V_i <- pop_params$V * exp(rnorm(1, 0, pop_params$CV_V))
  
  # Simulate concentrations
  conc <- simulate_pk(dose, CL_i, V_i, sampling_times, pop_params$SD_RES)
  
  # Create PC records
  pc_subj <- data.frame(
    STUDYID = "STUDY001",
    DOMAIN = "PC",
    USUBJID = subj_id,
    PCSEQ = 1:length(sampling_times),
    PCTEST = "Drug X",
    PCTESTCD = "DRUGX",
    PCORRES = ifelse(is.na(conc), "BLQ", as.character(round(conc, 2))),
    PCORRESU = "ng/mL",
    PCSTRESC = ifelse(is.na(conc), "BLQ", as.character(round(conc, 2))),
    PCSTRESN = conc,
    PCSTRESU = "ng/mL",
    PCDTC = format(dose_datetime + (sampling_times * 3600), "%Y-%m-%dT%H:%M"),
    PCTPT = c("PRE-DOSE", "0.5H", "1H", "2H", "4H", "8H", "12H", "24H"),
    PCTPTNUM = sampling_times,
    VISIT = "DAY 1",
    VISITNUM = 1,
    PCSPEC = "PLASMA",
    PCMETHOD = "LC-MS/MS"
  )
  
  pc_list[[i]] <- pc_subj
}

pc <- bind_rows(pc_list)

# ============================================================================
# 4. EXPORT DATASETS
# ============================================================================

dir.create("data-raw", showWarnings = FALSE, recursive = TRUE)

write.csv(dm, "data-raw/sdtm_dm.csv", row.names = FALSE)
write.csv(ex, "data-raw/sdtm_ex.csv", row.names = FALSE)
write.csv(pc, "data-raw/sdtm_pc.csv", row.names = FALSE)

message("\n=== SDTM Datasets Created ===")
message("DM (Demographics): ", nrow(dm), " subjects")
message("EX (Exposure): ", nrow(ex), " dosing records")
message("PC (Concentrations): ", nrow(pc), " concentration records")
message("\nFiles saved to data-raw/ directory")

# Summary statistics
message("\n=== Study Summary ===")
message("Dose levels: ", paste(unique(dm$ARMCD), collapse = ", "))
message("Age range: ", min(dm$AGE), " - ", max(dm$AGE), " years")
message("Sex distribution: ", sum(dm$SEX == "M"), " Male, ", sum(dm$SEX == "F"), " Female")
message("Sampling timepoints: ", paste(sampling_times, collapse = ", "), " hours")
