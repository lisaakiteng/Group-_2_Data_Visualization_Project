library(leaflet)
library(tidyverse)
library(readr)
library(sf)
library(gstat)
library(raster)
library(dplyr)


# Define color palette
category_colors_map <- c(
    "1" = "turquoise",      # Good
    "2" = "green",          # Fair
    "3" = "yellow",         # Moderate
    "4" = "orange",         # Poor
    "5" = "brown",          # Very Poor
    "6" = "darkviolet"      # Extremely Poor
)


################################# Main Graph ##################################

# Download Madrid districts GeoJSON data
# Source: Ayuntamiento de Madrid
url <- "https://raw.githubusercontent.com/codeforgermany/click_that_hood/master/public/data/madrid-districts.geojson"
madrid_geo <- st_read(url)

# Convert stations to an sf object using lat/lon
stations_sf <- st_as_sf(stations, coords = c("lon", "lat"), crs = 4326)


################################ Graphs (1x3) #################################

# 1. Get the data needed to make the example map (NO2 data for date 2017-12-20)
NO2_map_data <- madrid %>%
    filter(date == "2017-12-20", !is.na(NO_2)) %>%
    st_as_sf(coords = c("lon", "lat"), crs = 4326)

# 2. Project to a metric CRS for interpolation (e.g., UTM zone 30N for Madrid)
NO2_projected <- st_transform(NO2_map_data, crs = 25830)  # ETRS89 / UTM zone 30N

# 3. Create spatial grid
grid <- st_make_grid(st_union(NO2_projected), cellsize = 500, what = "centers")  # 500m grid
grid_sf <- st_sf(geometry = grid)

# 4. Convert to Spatial (needed for gstat)
NO2_sp <- as_Spatial(NO2_projected)
grid_sp <- as_Spatial(grid_sf)

# 5. IDW interpolation
idw_result <- idw(formula = NO_2 ~ 1, locations = NO2_sp, newdata = grid_sp, idp = 2.0)

# 6. Rasterize the interpolated values
gridded(idw_result) <- TRUE
r <- raster(idw_result)

# 7. Reproject raster back to WGS84 for leaflet
r_wgs84 <- projectRaster(r, crs = CRS("EPSG:4326"))

# 8. Categorize into EAQI levels
reclass_matrix <- matrix(c(
    0,    40,  1,
    40,  90,  2,
    90, 120,  3,
    120, 230,  4,
    230, 340,  5,
    340, 1000,  6
), ncol = 3, byrow = TRUE)

r_cat <- reclassify(r_wgs84, reclass_matrix)

rm(NO2_map_data, NO2_projected, grid, grid_sf, NO2_sp, grid_sp,
   idw_result, r, r_wgs84, reclass_matrix)
