test_that("validate_nonmem_data detects missing required variables", {
  # Dataset missing EVID column
  bad_data <- data.frame(
    ID = c(1, 1),
    TIME = c(0, 1),
    DV = c(NA, 15),
    AMT = c(100, 0)
    # Missing EVID, CMT, MDV
  )
  
  result <- validate_nonmem_data(bad_data)
  
  expect_false(result$valid)
  expect_true(length(result$errors) > 0)
  expect_match(result$errors[1], "Missing required variables")
})

test_that("validate_nonmem_data checks for negative TIME", {
  bad_data <- data.frame(
    ID = c(1, 1),
    TIME = c(-1, 1),  # Negative time
    DV = c(NA, 15),
    AMT = c(100, 0),
    EVID = c(1, 0),
    CMT = c(1, 2),
    MDV = c(1, 0)
  )
  
  result <- validate_nonmem_data(bad_data)
  
  expect_false(result$valid)
  expect_true(any(grepl("negative values", result$errors)))
})

test_that("validate_nonmem_data checks dosing records have AMT > 0", {
  bad_data <- data.frame(
    ID = c(1, 1),
    TIME = c(0, 1),
    DV = c(NA, 15),
    AMT = c(0, 0),  # Dosing record with AMT = 0
    EVID = c(1, 0),
    CMT = c(1, 2),
    MDV = c(1, 0)
  )
  
  result <- validate_nonmem_data(bad_data)
  
  expect_false(result$valid)
  expect_true(any(grepl("AMT > 0", result$errors)))
})

test_that("validate_nonmem_data passes with valid dataset", {
  good_data <- data.frame(
    ID = c(1, 1, 1),
    TIME = c(0, 1, 2),
    DV = c(NA, 15, 10),
    AMT = c(100, 0, 0),
    EVID = c(1, 0, 0),
    CMT = c(1, 2, 2),
    MDV = c(1, 0, 0)
  )
  
  result <- validate_nonmem_data(good_data)
  
  expect_true(result$valid)
  expect_equal(length(result$errors), 0)
})

test_that("validate_nonmem_data generates summary statistics", {
  data <- data.frame(
    ID = c(1, 1, 2, 2),
    TIME = c(0, 1, 0, 1),
    DV = c(NA, 15, NA, 20),
    AMT = c(100, 0, 100, 0),
    EVID = c(1, 0, 1, 0),
    CMT = c(1, 2, 1, 2),
    MDV = c(1, 0, 1, 0)
  )
  
  result <- validate_nonmem_data(data)
  
  expect_s3_class(result$summary, "data.frame")
  expect_true(nrow(result$summary) > 0)
  expect_true("metric" %in% names(result$summary))
  expect_true("value" %in% names(result$summary))
})
