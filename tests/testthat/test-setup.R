devtools::load_all()
library(projmgr)

test_that("get_secret function works", {
  if (Sys.getenv("DEPOT_API_SECRET") == "") {
    expect_error(get_secret(), "No DEPOT_API_SECRET - Please set env var DEPOT_API_SECRET to your secret that you received using store_secret_credentials function")
  }else{
    expect_equal(get_secret(), Sys.getenv("DEPOT_API_SECRET"))
  }
})

test_that("get_secret_email function works", {
  if (Sys.getenv("DEPOT_API_SECRET_EMAIL") == "") {
    expect_error(get_secret(), "No DEPOT_API_SECRET_EMAIL - Please set env var DEPOT_API_SECRET_EMAIL to the email address where you received your secret using store_secret_credentials function")
  }else{
    expect_equal(get_secret_email(), Sys.getenv("DEPOT_API_SECRET_EMAIL"))
  }
})

test_that("get_token function works", {

  #INTERNET <- TRUE
  INTERNET <- check_internet()

  .s <- get_secret()
  .e <- get_secret_email()
  if (INTERNET & .s != "" & .e != "") {
    #expect_equal(typeof(get_token()), "character")
    expect_equal(typeof(get_token()), "raw")
    expect_equal(get_token(email_address = "not_valid@gmail.com",
                       secret = "not_valid"), "Invalid credentials")
  }else{
    skip("API not available either due to no internet or incorrect credentials")
  }

})
