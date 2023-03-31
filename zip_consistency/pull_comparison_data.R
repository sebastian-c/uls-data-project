library(FAOSTAT) # >=2.3.0
library(data.table)

# Doing this without groups

# Production and Forestry

dataset_code <- c("OA", "FBS", "QCL", "FO")[4]

dataset_dimensions <- read_dataset_dimension(dataset_code)
setDT(dataset_dimensions)

# Maybe doing it by year would be more sensible? There are ~200 countries and
# only about ~70 years
# Nope - country is better. That way you don't have annoying groups
year_list <- read_dimension_metadata(dataset_code, "years")


comparison_frame <- data.table(year = year_list[["Year"]],
                               rest_rows = NA_integer_,
                               zip_rows = NA_integer_)

zip_data <- get_faostat_bulk(dataset_code)
setDT(zip_data)

for (year_index in seq_len(nrow(comparison_frame))){
 
  year_code = comparison_frame[year_index, year]
  
  message(comparison_frame[year == year_code, year], 
          sprintf(" (%s/%s)", year_index, nrow(comparison_frame)))
  
  rest_data <- try(read_fao(dataset_code, 
                            item_format = "FAO",
                            year_codes = year_code, 
                            clean_format = "snake_case"))
  
  n_tries = 2
  total_tries = 3
  while(inherits(rest_data, "try-error") && n_tries < total_tries){
  
    message(paste0("Error encountered while retrieving data. Possible rate limitation.",
                   "\nWaiting 10 seconds and trying again.",
                   "\nAttempt ", n_tries, " of ", total_tries))
    Sys.sleep(10)
    
    rest_data <- try(read_fao(dataset_code, year_codes = year_code, clean_format = "snake_case"))
    
    n_tries = n_tries + 1
  }
  
  if(n_tries >= total_tries){
    warning(year_index, " could not be processed, leaving it blank")
    next
  }
  year_zip_data <- zip_data[as.character(year) == get("year_code", envir = parent.frame()),]
  
  comparison_frame[year == year_code, `:=`(
    rest_rows = nrow(rest_data),
    zip_rows = nrow(year_zip_data)
  )]
  
  
}

comparison_frame[rest_rows != zip_rows]


z = year_zip_data
r = rest_data

setDT(z)
setDT(r)

z[,  `:=`(area_code = as.character(area_code),
          item_code = as.integer(item_code))]

zr_join = c(area = "area", item_code = "item_code__fao_", 
            element_code = "element_code" ,
            year = "year")

rz_join = setNames(names(zr_join), zr_join)

z[!r, on = zr_join][, .N, by = area]

r[!z, on = rz_join]
