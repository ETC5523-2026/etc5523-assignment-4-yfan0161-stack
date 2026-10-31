test_that("calculate_risk returns grid values and interpolates", {
  expect_equal(calculate_risk(3, 0), 1)
  expect_equal(calculate_risk(6, 0.5), 1.01)
  expect_equal(calculate_risk(6, 0.6), 0.74)
  expect_equal(calculate_risk(2.5, 0.25), 0.427)
  expect_length(calculate_risk(c(2, 4, 6), 0.5), 3)
})

test_that("calculate_risk rejects invalid input", {
  expect_error(calculate_risk(11, 0.5), "between")
  expect_error(calculate_risk(6, 0.95), "between")
  expect_error(calculate_risk(NA_real_, 0.5), "missing")
  expect_error(calculate_risk("a", 0.5), "numeric")
})

test_that("find_threshold_ve behaves sensibly", {
  expect_equal(find_threshold_ve(6), 0.504)
  expect_equal(find_threshold_ve(3), 0)
  expect_true(is.na(find_threshold_ve(10, target = 0.1)))
  expect_error(find_threshold_ve(6, target = 0), "greater than 0")
  expect_error(find_threshold_ve(0.5), "between")
})