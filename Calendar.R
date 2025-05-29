library(leaflet)
library(tidyverse)
library(readr)
library(sf)
library(gstat)
library(raster)
library(dplyr)

# Define color palette
category_colors <- c(
    "Good" = "turquoise",
    "Fair" = "green",
    "Moderate" = "yellow",
    "Poor" = "orange",
    "Very Poor" = "brown",
    "Extremely Poor" = "darkviolet"
)

#Grading Function
fn_grade <- function(df) {
    df_result <-
        df %>%
        mutate(PM10_cat = case_when( between(PM10, 0,20)        ~ "Good",
                                     between(PM10, 20,40)       ~ "Fair",
                                     between(PM10, 40,50)       ~ "Moderate",
                                     between(PM10, 50,100)      ~ "Poor",
                                     between(PM10, 100,150)     ~ "Very Poor",
                                     between(PM10, 150,200)     ~ "Extremely Poor"
                                     ),
               NO_2_cat = case_when( between(NO_2, 0,40)        ~ "Good",
                                     between(NO_2, 40,90)       ~ "Fair",
                                     between(NO_2, 90,120)      ~ "Moderate",
                                     between(NO_2, 120,230)     ~ "Poor",
                                     between(NO_2, 230,340)     ~ "Very Poor",
                                     between(NO_2, 340,1000)    ~ "Extremely Poor"
                                     ),
               O_3_cat = case_when(  between(O_3,0,50)          ~ "Good",
                                     between(O_3,50,100)        ~ "Fair",
                                     between(O_3,100,130)       ~ "Moderate",
                                     between(O_3,130,240)       ~ "Poor",
                                     between(O_3,240,380)       ~ "Very Poor",
                                     between(O_3,380,800)       ~ "Extremely Poor"
                                     )
               ) %>%
        mutate(
            PM10_cat = factor(PM10_cat, levels = names(category_colors)),
            NO_2_cat = factor(NO_2_cat, levels = names(category_colors)),
            O_3_cat = factor(O_3_cat, levels = names(category_colors))
        )
    return(df_result)
}

#Update main dataframe
madrid <- fn_grade(madrid)