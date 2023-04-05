library(FAOSTAT)
library(data.table)
library(ggplot2)

raw_data <- get_faostat_bulk("RL")
setDT(raw_data)

flag_map <- c("A" = "Official figure",
              "E" = "Estimated value",
              "I" = "Imputed value",
              "P" = "Provisional value",
              "T" = "Unofficial figure")

raw_data[, flag := flag_map[flag]]

ggplot(raw_data[area == "Afghanistan"], aes(x = year, y = item, fill = flag)) +
  geom_tile()
