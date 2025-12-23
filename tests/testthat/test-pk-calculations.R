test_that("calculate_pk_parameters computes basic PK parameters", {
  # Simple test data
  time <- c(0, 1, 2, 4, 8, 12, 24)
  conc <- c(0, 15, 20, 18, 10, 5, 1)
  dose <- 100
  
  result <- calculate_pk_parameters(time, conc, dose)
  
  expect_type(result, "list")
  expect_true("Cmax" %in% names(result))
  expect_true("Tmax" %in% names(result))
  expect_true("AUC_last" %in% names(result))
  expect_equal(result$Cmax, 20)
  expect_equal(result$Tmax, 2)
  expect_true(result$AUC_last > 0)
})

test_that("calculate_pk_parameters handles insufficient data", {
  time <- c(0, 1)
  conc <- c(0, 15)
  dose <- 100
  
  expect_warning(
    result <- calculate_pk_parameters(time, conc, dose),
    "Insufficient data points"
  )
  
  expect_null(result)
})

test_that("calculate_pk_parameters handles missing values", {
  time <- c(0, 1, 2, NA, 4)
  conc <- c(0, 15, 20, 18, NA)
  dose <- 100
  
  result <- calculate_pk_parameters(time, conc, dose)
  
  # Should work with valid points only
  expect_type(result, "list")
  expect_true(!is.na(result$Cmax))
})

test_that("summarize_pk_by_subject works with NONMEM dataset", {
  # Create minimal NONMEM dataset
  nonmem_data <- data.frame(
    ID = c(1, 1, 1, 1, 2, 2, 2, 2),
    TIME = c(0, 1, 2, 4, 0, 1, 2, 4),
    DV = c(NA, 15, 20, 10, NA, 12, 18, 8),
    AMT = c(100, 0, 0, 0, 100, 0, 0, 0),
    EVID = c(1, 0, 0, 0, 1, 0, 0, 0),
    CMT = c(1, 2, 2, 2, 1, 2, 2, 2),
    MDV = c(1, 0, 0, 0, 1, 0, 0, 0)
  )
  
  result <- summarize_pk_by_subject(nonmem_data)
  
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)  # 2 subjects
  expect_true("ID" %in% names(result))
  expect_true("Cmax" %in% names(result))
  expect_true("AUC_last" %in% names(result))
})
