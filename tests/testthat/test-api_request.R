test_that("api request works", {

  #INTERNET <- httr::GET("www.google.com")$status_code
  #INTERNET = ifelse(INTERNET == 200, T, F)
  INTERNET = T

  if (INTERNET){
    TOKEN <- get_token()
  }else{
    TOKEN <- "Invalid credentials"
  }

  if(TOKEN != "Invalid credentials" & INTERNET){
    r <- tidy_depot_api(path = "Biochemistry", token = TOKEN)
    expect_equal(S3Class(r), "tidy_depot_api")
    expect_equal(S3Class(r$content), "data.frame")
    expect_equal(S3Class(r$response), "response")
    expect_equal(r$path, "Biochemistry")
  }else{
    skip("API not available either due to no internet or incorrect credentials")
  }

})
