library(FAOSTAT) # >=2.3.0, feature branch
library(data.table)

# Doing this without groups



datasets <- search_dataset()
dataset_code <- datasets[1,"code"]

dataset_dimensions <- read_dataset_dimension(dataset_code)
setDT(dataset_dimensions)

metadata_codes <- c("flag", "unit", "glossary")
group_codes <- grep("group$", dataset_dimensions[,code], value = TRUE)

dimensions <- setdiff(dataset_dimensions[, code], c(metadata_codes, group_codes))


dimension_metadata <- dimensions[1]
dimension_values <- read_dimension_metadata(dataset_code, dimension_metadata)

coll <- function(string){
  paste0(string, collapse = ",")
}

params_list <- list(code = coll(dimension_values[,1]))

names(params_list) <- dimension_metadata

#debugonce(FAOSTAT:::get_fao)

rest_data <- read_fao_list(dataset_code, params_list)

names(rest_data) <- FAOSTAT:::to_snake(names(rest_data))

#debugonce(download_faostat_bulk)
zip_data <- get_faostat_bulk(dataset_code)


