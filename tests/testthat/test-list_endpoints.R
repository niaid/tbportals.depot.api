test_that("list_endpoints() works", {
  expect_equal(list_endpoints(), data.frame(
    endpoint = c("Biochemistry", "CT", "CT-Annotation",
                 "CXR", "CXR-Manual-Annotation", "CXR-Qure-Annotation",
                 "DST", "Genomics", "Patient-Case", "Specimen",
                 "Treatment-Regimen"),
    description = c("Laboratory and biochemistry records information",
                    "Computed Tomagraphy records information",
                    "Computed Tomagraphy records radiologist annotations",
                    "Chest X ray records information",
                    "Chest X ray records radiologist annotations",
                    "Chest X ray records Qure AI algorithm annotations",
                    "Drug sensitivity testing results records",
                    "Pathogen genomics records information",
                    "Patient case record information",
                    "Specimen record information",
                    "Treatment and regiment record information")
  ))
})
