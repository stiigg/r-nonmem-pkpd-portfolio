test_that("create_nonmem_dataset works with valid SDTM data", {
  # Create minimal test data
  pc_data <- data.frame(
    USUBJID = c("001", "001", "001"),
    PCDTC = c("2025-01-01T08:00", "2025-01-01T09:00", "2025-01-01T12:00"),
    PCSTRESN = c(0, 15, 10),
    PCTPTNUM = c(0, 1, 4)
  )
  
  ex_data <- data.frame(
    USUBJID = c("001"),
    EXSTDTC = c("2025-01-01T08:00"),
    EXDOSE = c(100)
  )
  
  dm_data <- data.frame(
    USUBJID = c("001"),
    AGE = c(45),
    SEX = c("M")
  )
  
  # Test conversion
  result <- create_nonmem_dataset(
    pc_data = pc_data,
    ex_data = ex_data,
    dm_data = dm_data,
    study_id = "TEST001"
  )
  
  # Assertions
  expect_s3_class(result, "data.frame")
  expect_true("ID" %in% names(result))
  expect_true("TIME" %in% names(result))
  expect_true("DV" %in% names(result))
  expect_true("EVID" %in% names(result))
  expect_equal(nrow(result), 4)  # 1 dose + 3 concentrations
  expect_equal(sum(result$EVID == 1), 1)  # 1 dosing record
  expect_equal(sum(result$EVID == 0), 3)  # 3 observation records
})

test_that("create_nonmem_dataset handles missing concentrations", {
  pc_data <- data.frame(
    USUBJID = c("001", "001"),
    PCDTC = c("2025-01-01T09:00", "2025-01-01T12:00"),
    PCSTRESN = c(15, NA),
    PCTPTNUM = c(1, 4)
  )
  
  ex_data <- data.frame(
    USUBJID = c("001"),
    EXSTDTC = c("2025-01-01T08:00"),
    EXDOSE = c(100)
  )
  
  dm_data <- data.frame(
    USUBJID = c("001"),
    AGE = c(45),
    SEX = c("M")
  )
  
  result <- create_nonmem_dataset(pc_data, ex_data, dm_data)
  
  # Missing DV should have MDV = 1
  missing_row <- result[is.na(result$DV) & result$EVID == 0, ]
  expect_equal(missing_row$MDV, 1)
})

test_that("create_nonmem_dataset validates required variables", {
  # Missing required PC variable
  pc_data <- data.frame(
    USUBJID = c("001"),
    PCDTC = c("2025-01-01T09:00")
    # Missing PCSTRESN
  )
  
  ex_data <- data.frame(
    USUBJID = c("001"),
    EXSTDTC = c("2025-01-01T08:00"),
    EXDOSE = c(100)
  )
  
  dm_data <- data.frame(
    USUBJID = c("001"),
    AGE = c(45),
    SEX = c("M")
  )
  
  expect_error(
    create_nonmem_dataset(pc_data, ex_data, dm_data),
    "PC domain missing required variables"
  )
})
