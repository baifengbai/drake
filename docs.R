faq <- function(){
  library(tidyverse)
  library(gh)

  is_faq <- function(label){
    identical(label$name, "frequently asked question")
  }

  any_faq_label <- function(issue){
    any(vapply(issue$labels, is_faq, logical(1)))
  }

  faq <- gh(
    "GET /repos/ropensci/drake/issues?state=all",
    .limit = Inf
  ) %>%
    Filter(f = any_faq_label)

  combine_fields <- function(lst, field){
    map_chr(lst, function(x){
      x[[field]]
    })
  }

  titles <- combine_fields(faq, "title")
  urls <- combine_fields(faq, "html_url")
  links <- paste0("- [", titles, "](", urls, ")")

  starter <- system.file(
    file.path("stubs", "faq.Rmd"),
    package = "drake",
    mustWork = TRUE
  )
  dir <- rprojroot::find_root(criterion = "DESCRIPTION", path = getwd())
  dest <- file.path(dir, "vignettes", "faq.Rmd")
  tmp <- file.copy(
    from = starter,
    to = dest,
    overwrite = TRUE
  )

  con <- file(dest, "a")
  writeLines(c("", links), con)
  close(con)
}

pkgdown <- function(){
  dir <- rprojroot::find_root(criterion = "DESCRIPTION", path = getwd())
  site_dir <- file.path(dir, "docs")
  if (!file.exists(site_dir)){
    dir.create(site_dir)
  }
  index_file <- file.path(site_dir, "index.html")
  tmp <- pkgdown::build_site(pkg = dir, preview = FALSE)

  x <- readLines(index_file)
  from <- '<p><a href="https://ropensci.github.io/drake/images/pitch3.html"><img src=".*graph.png"></a></p>' # nolint
  to <- "<iframe
    src = 'https://ropensci.github.io/drake/images/pitch3.html'
    width = '100%' height = '600px' allowtransparency='true'
    style='border: none; box-shadow: none'>
    </iframe>"
  x <- gsub(pattern = from, replacement = to, x = x)

  from <- "<title>.*</title>"
  to <- paste(
    "<title>drake</title>",
    "<link rel=\"drake icon\" type = \"image/x-icon\" href=\"icon.ico\"/>", # nolint
    collapse = "\n"
  )
  x <- gsub(pattern = from, replacement = to, x = x)

  tmp <- writeLines(text = x, con = index_file)
  unlink(
    c(
      file.path(site_dir, "*.rds"),
      file.path(site_dir, "file*"),
      file.path(site_dir, "preview-")
    ),
    recursive = TRUE
  )
}

# Generate the HTML widgets in the docs/images/ folder.
# These interactive graphs are embedded in the vignettes.
# Requires pandoc.
images <- function(){
  library(here)
  library(tidyverse)
  html_out <- function(...) here::here("docs", "images", ...)
  for (dir in c(here::here("docs"), here::here("docs", "images"))){
    if (!file.exists(dir)){
      dir.create(dir)
    }
  }
  for (img in list.files(here::here("images"))){
    file.copy(
      here::here("images", img),
      here::here("docs", "images", img),
      overwrite = TRUE
    )
  }
  file.copy(
    here::here("docs", "images", "icon.ico"),
    here::here("docs", "icon.ico"),
    overwrite = TRUE
  )
  devtools::load_all() # load current drake
  clean(destroy = TRUE)
  config <- load_mtcars_example(overwrite = TRUE)
  vis_drake_graph(
    config, file = html_out("outdated.html"), selfcontained = TRUE,
                  width = "100%", height = "500px")
  config <- make(my_plan)
  vis_drake_graph(config, file = html_out("built.html"), selfcontained = TRUE,
                  width = "100%", height = "500px")
  reg2 <- function(d){
    d$x3 <- d$x ^ 3
    lm(y ~ x3, data = d)
  }
  vis_drake_graph(config, file = html_out("reg2.html"), selfcontained = TRUE,
                  width = "100%", height = "500px")
  vis_drake_graph(
    config, file = html_out("reg2-small-legend.html"), selfcontained = TRUE,
                  width = "100%", height = "500px", full_legend = FALSE)
  vis_drake_graph(
    config, file = html_out("reg2-no-legend.html"), selfcontained = TRUE,
                  width = "100%", height = "500px", ncol_legend = 0)
  vis_drake_graph(
    config, file = html_out("targetsonly.html"), selfcontained = TRUE,
    targets_only = TRUE,
    width = "100%", height = "500px",
    from = c("large", "small")
  )
  vis_drake_graph(
    config, file = html_out("fromout.html"), selfcontained = TRUE,
    width = "100%", height = "500px",
    from = c("regression2_small", "regression2_large")
  )
  vis_drake_graph(
    config, file = html_out("fromin.html"), selfcontained = TRUE,
    width = "100%", height = "500px",
    from = "small", mode = "in"
  )
  vis_drake_graph(
    config, file = html_out("fromall.html"), selfcontained = TRUE,
    width = "100%", height = "500px",
    from = "small", mode = "all", order = 1
  )
  vis_drake_graph(
    config, file = html_out("subset.html"), selfcontained = TRUE,
    width = "100%", height = "500px",
    subset = c("regression2_small", "\"report.md\"")
  )
  clean(destroy = TRUE)
  unlink("report.Rmd")

  # For the "packages" example.
  rm(config)
  library(magrittr)
  reportfile <- file.path("examples", "packages", "report.Rmd") %>%
    system.file(package = "drake", mustWork = TRUE)
  file.copy(reportfile, getwd())
  runfile <- file.path("examples", "packages", "interactive-tutorial.R") %>%
    system.file(package = "drake", mustWork = TRUE)
  source(runfile)
  vis_drake_graph(
    config, file = html_out("packages.html"), selfcontained = TRUE,
    width = "100%", height = "500px"
  )

  # For the best practices vignette
  get_data <- function(){
    "Get the data."
  }
  analyze_data <- function(){
    "Analyze the data."
  }
  summarize_results <- function(){
    "Summarize the results."
  }
  files <- c("data.csv", "get_data.R", "analyze_data.R", "summarize_data.R")
  for (file in files){
    file.create(file)
  }
  my_plan <- drake_plan(
    my_data = get_data(file_in("data.csv")),
    my_analysis = analyze_data(my_data),
    my_summaries = summarize_results(my_data, my_analysis),
    strings_in_dots = "literals"
  )
  config <- drake_config(my_plan)
  vis_drake_graph(
    main = "Good workflow plan",
    config, file = html_out("good-commands.html"), selfcontained = TRUE,
    width = "100%", height = "500px"
  )
  my_plan <- drake_plan(
    my_data = source(file_in("get_data.R")),
    my_analysis = source(file_in("analyze_data.R")),
    my_summaries = source(file_in("summarize_data.R")),
    strings_in_dots = "literals"
  )
  config <- drake_config(my_plan)
  vis_drake_graph(
    main = "Bad workflow plan",
    config, file = html_out("bad-commands.html"), selfcontained = TRUE,
    width = "100%", height = "500px"
  )
  for (file in files){
    file.remove(file)
  }
  clean(destroy = TRUE)
  unlink(c("figure", "report.Rmd"), recursive = TRUE)
  unlink(html_out("*_files"), recursive = TRUE)

  # drake.Rmd vignette
  pkgconfig::set_config("drake::strings_in_dots" = "literals")
  dat <- system.file(
    file.path("examples", "main", "raw_data.xlsx"),
    package = "drake",
    mustWork = TRUE
  )
  tmp <- file.copy(from = dat, to = "raw_data.xlsx", overwrite = TRUE)
  rmd <- system.file(
    file.path("examples", "main", "report.Rmd"),
    package = "drake",
    mustWork = TRUE
  )
  tmp <- file.copy(from = rmd, to = "report.Rmd", overwrite = TRUE)
  plan <- drake_plan(
    raw_data = readxl::read_excel(file_in("raw_data.xlsx")),
    data = raw_data %>%
      mutate(Species = forcats::fct_inorder(Species)),
    hist = create_plot(data),
    fit = lm(Sepal.Width ~ Petal.Width + Species, data),
    knitr::knit(
      knitr_in("report.Rmd"),
      output = file_out("report.md"),
      quiet = TRUE
    )
  )
  create_plot <- function(data) {
    ggplot(data, aes(x = Petal.Width, fill = Species)) +
      geom_histogram()
  }
  config <- drake_config(plan)
  vis_drake_graph(
    config, from = file_store("raw_data.xlsx"), mode = "out",
    build_times = "none", ncol_legend = 0, width = "100%",
    height = "500px", selfcontained = TRUE,
    file = html_out("pitch1.html")
  )
  make(plan)
  plan <- drake_plan(
    raw_data = readxl::read_excel(file_in("raw_data.xlsx")),
    data = raw_data %>%
      mutate(Species = forcats::fct_inorder(Species)) %>%
      select(-X__1),
    hist = create_plot(data),
    fit = lm(Sepal.Width ~ Petal.Width + Species, data),
    knitr::knit(
      knitr_in("report.Rmd"),
      output = file_out("report.md"),
      quiet = TRUE
    )
  )
  config <- drake_config(plan)
  vis_drake_graph(
    config, from = file_store("raw_data.xlsx"), mode = "out",
    build_times = "none", full_legend = FALSE, width = "100%",
    height = "500px", selfcontained = TRUE,
    file = html_out("pitch2.html")
  )
  make(plan)
  create_plot <- function(data) {
    ggplot(data, aes(x = Petal.Width, fill = Species)) +
      geom_histogram(binwidth = 0.25) +
      theme_gray(20)
  }
  config <- drake_config(plan)
  vis_drake_graph(
    config, from = file_store("raw_data.xlsx"), mode = "out",
    build_times = "none", full_legend = FALSE, width = "100%",
    height = "500px", selfcontained = TRUE,
    file = html_out("pitch3.html")
  )
  unlink("raw_data.xlsx")

  # Staged parallelism
  library(dplyr)
  N <- 500
  gen_data <- function() {
    tibble(a = seq_len(N), b = 1, c = 2, d = 3)
  }
  plan_data <- drake_plan(
    data = gen_data()
  )
  plan_sub <-
    gen_data() %>%
    transmute(
      target = paste0("data", a),
      command = paste0("data[", a, ", ]")
    )
  plan <- bind_rows(plan_data, plan_sub)
  config <- drake_config(plan)
  vis_drake_graph(
    config, width = "100%",
    height = "500px", selfcontained = TRUE,
    file = html_out("staged.html")
  )

  # Clean up the rest.
  clean(destroy = TRUE)
  unlink(c("figure", "report.Rmd"), recursive = TRUE)
  unlink(html_out("*_files"), recursive = TRUE)
}

faq()
pkgdown()
images()
