library(leaflet)
library(tidyverse)
library(readr)
library(sf)

df_barplot <- 
    madrid %>%
    group_by(year, name) %>%
    summarise(
        avg_NO2 = mean(NO_2),
        days_PM10_gt_50 = sum(PM10 > 50),
        days_max_O3_gt_30 = sum(O_3 > 180),
        .groups = "drop"
    )