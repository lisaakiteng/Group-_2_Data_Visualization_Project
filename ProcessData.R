library(leaflet)
library(tidyverse)
library(lubridate)
library(readr)
library(sf)

############################# IMPORT & CLEAN DATA #############################
stations <- read_csv("raw_data/stations.csv")

expected_cols <- c("date", "PM10", "NO_2", "O_3", "station")

for (x in 2001:2018) {
    df <- read_csv(str_c("raw_data/madrid_", x, ".csv")) %>%
        select(any_of(expected_cols))
    
    missing_cols <- setdiff(expected_cols, names(df))
    for (col in missing_cols) {
        df[[col]] <- NA
    }
    
    df <- df[expected_cols]
    assign(str_c("m_", x), df)
}

madrid <- 
    rbind(m_2001, m_2002, m_2003, m_2004, m_2005, m_2006,
          m_2007, m_2008, m_2009, m_2010, m_2011, m_2012,
          m_2013, m_2014, m_2015, m_2016, m_2017, m_2018) %>%
    mutate(date = as.Date(date)) %>%
    group_by(date, station) %>%
    summarise(NO_2 = mean(NO_2, na.rm=T),
              PM10 = mean(PM10, na.rm=T),
              O_3 = max(O_3, na.rm = T),
              obs = n()) %>% 
    #Keep only existing stations
    inner_join( y = stations,
                by = c("station" = "id")
                ) %>%
    mutate(year = lubridate::year(date),
           # fix -Inf results in O_3 (by marking them as missing data)
           O_3 = ifelse(is.infinite(O_3), NA, O_3))
    
rm(list=setdiff(ls(), c("madrid", "stations")))

readr::write_csv(madrid, "processed_data/madrid.csv")
readr::write_csv(stations, "processed_data/stations.csv")