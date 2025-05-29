library(shiny)
library(shinydashboard)
library(lubridate)

source("ImportData.R", local = TRUE)
source("Map.R", local = TRUE)
source("Barplot.R", local = TRUE)
source("Calendar.R", local = TRUE)

#################################### Shiny ####################################
# UI
ui <- dashboardPage( 
    dashboardHeader(title = "G2's Dashboard"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Pollution and air quality",
                     tabName = "map_tab", icon = icon("map")),
            menuItem("Pollution yearly evolution",
                     tabName = "barplot_tab", icon = icon("chart-bar")),
            menuItem("Pollutants daily evolution",
                     tabName = "calendar_tab", icon = icon("calendar"))
        )
    ),
    dashboardBody(
        tabItems(
            # Maps Tab
            tabItem(tabName = "map_tab",
                    fluidRow(
                        box(width = 12, leafletOutput("map"))
                    ),
                    fluidRow(
                        column(width = 12, align = "center",
                               tags$h3("Maps of concentrations of three principal pollutants")
                        )
                    ),
                    fluidRow(
                        box(width = 4, leafletOutput("map1")),
                        box(width = 4, leafletOutput("map2")),
                        box(width = 4, leafletOutput("map3"))
                    )
            )
            ,
            # Barplot Tab
            tabItem(tabName = "barplot_tab",
                    # Filter row
                    fluidRow(
                        box(width = 12,
                            selectInput("name_cal", "Select Station:",
                                        choices = sort(unique(madrid$name)),
                                        selected = "Escuelas Aguirre")
                        )
                    ),
                    # First barplot row
                    fluidRow(
                        box(width = 8, plotOutput("barplot1")),
                        box(width = 4, p("The red line indicates the European Union guideline that the number of days per year with a concentration of small particles above 50 μg/m³ should be no higher than 35 days to prevent adverse health effects."))
                    ),
                    # Second barplot row
                    fluidRow(
                        box(width = 8, plotOutput("barplot2")),
                        box(width = 4, p("The 180 μg/m³ threshold is the European Union threshold for information of the public, so the number of days that this threshold is exceeded should be as low as possible."))
                    ),
                    # Third barplot row
                    fluidRow(
                        box(width = 8, plotOutput("barplot3")),
                        box(width = 4, p("The red line indicates the World Health Organization guideline that the yearly average concentration of NO₂ should not exceed 40 μg/m³ to prevent adverse health effects."))
                    )
            ),
            tabItem(tabName = "calendar_tab",
                    # Filters
                    fluidRow(
                        box(width = 6,
                            selectInput("name_cal", "Select Station:",
                                        choices = sort(unique(madrid$name)),
                                        selected = "Escuelas Aguirre")
                        ),
                        box(width = 6,
                            selectInput("year_cal", "Select Year:",
                                        choices = sort(unique(madrid$year)),
                                        selected = 2014)
                        )
                    ),
                    # Three vertically stacked calendar plots
                    fluidRow(
                        box(width = 12, plotOutput("calendar1"))
                    ),
                    fluidRow(
                        box(width = 12, plotOutput("calendar2"))
                    ),
                    fluidRow(
                        box(width = 12, plotOutput("calendar3"))
                    )
            )
        )
    )
)

# Server
server <- function(input, output) {
    
    # Map tab
    output$map <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            addPolygons(data = madrid_geo,
                        color = "black",
                        weight = 1, 
                        fillColor = "transparent",
                        fillOpacity = 0,
                        popup = ~name) %>%
            addCircleMarkers(data = stations_sf,
                             radius = 5,
                             color = "red",
                             label = ~name,
                             popup = ~paste0("<strong>Station: </strong>", name)) %>%
            addControl(
                html = "<div style='background-color: rgba(255,255,255,0.8); padding: 5px; border-radius: 4px; font-size: 12px;'>
                        <b>Red dots:</b> Measurement stations
                    </div>",
                position = "bottomleft"
            )
    })
    
    #Same graph as for NO_2
    output$map1 <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            addRasterImage(r_cat, colors = category_colors_map, opacity = 0.7, project = FALSE) %>%
            addLegend(
                "bottomright",
                colors = unname(category_colors),
                labels = c("Good", "Fair", "Moderate", "Poor", "Very Poor", "Extremely Poor"),
                title = "PM10 (EAQI Category)",
                opacity = 1
            ) %>%
            addPolygons(data = madrid_geo, color = "black", weight = 1, fillOpacity = 0)
    })
    
    #Same graph as for NO_2
    output$map2 <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            addRasterImage(r_cat, colors = category_colors_map, opacity = 0.7, project = FALSE) %>%
            addLegend(
                "bottomright",
                colors = unname(category_colors),
                labels = c("Good", "Fair", "Moderate", "Poor", "Very Poor", "Extremely Poor"),
                title = "O₃ (EAQI Category)",
                opacity = 1
            ) %>%
            addPolygons(data = madrid_geo, color = "black", weight = 1, fillOpacity = 0)
    })
    
    output$map3 <- renderLeaflet({leaflet() %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            addRasterImage(r_cat, colors = category_colors_map, opacity = 0.7, project = FALSE) %>%
            addLegend(
                "bottomright",
                colors = unname(category_colors),
                labels = c("Good", "Fair", "Moderate", "Poor", "Very Poor", "Extremely Poor"),
                title = "NO₂ (EAQI Category)",
                opacity = 1
            ) %>%
            addPolygons(data = madrid_geo, color = "black", weight = 1, fillOpacity = 0)})
    
    # Barplot tab
    
    output$barplot1 <- renderPlot({
        # Ensure inputs are available
        req(input$name_cal)
        
        ggplot(df_barplot %>% filter(name == input$name_cal),
               aes(x = factor(year), y = days_PM10_gt_50)) +
            geom_col(fill = "steelblue") +
            geom_hline(yintercept = 35, color = "red", linetype = "solid", size = 1.2) +
            labs(
                title = "Number of days per year with concentration of small particles (PM10) > 50 μg/m³",
                x = "Year",
                y = "Number of Days"
            ) +
            theme_classic(base_size = 14)
    })
    output$barplot2 <- renderPlot({
        # Ensure inputs are available
        req(input$name_cal)
        
        ggplot(df_barplot %>% filter(name == input$name_cal),
               aes(x = factor(year), y = days_max_O3_gt_30)) +
            geom_col(fill = "steelblue") +
            labs(
                title = "Number of days per year with maximum concentration of ozone (O₃) > 180 μg/m³",
                x = "Year",
                y = "Number of Days"
            ) +
            theme_classic(base_size = 14)
    })
    
    output$barplot3 <- renderPlot({
        # Ensure inputs are available
        req(input$name_cal)
        
        ggplot(df_barplot %>% filter(name == input$name_cal),
               aes(x = factor(year), y = avg_NO2)) +
            geom_col(fill = "steelblue") +
            geom_hline(yintercept = 40, color = "red", linetype = "solid", size = 1.2) +
            labs(
                title = "Yearly average nitrogen dioxide (NO₂) concentration (μ/m³)",
                x = "Year",
                y = "Average NO₂ (µg/m³)"
            ) +
            theme_classic(base_size = 14)
        
    })
    
    # Calendar tab
    output$calendar1 <- renderPlot({
        # Ensure inputs are available
        req(input$name_cal, input$year_cal)
        
        ggplot(madrid %>%
                   filter(name == input$name_cal,
                          year == input$year_cal),
               aes(x = day(date),
                   y = fct_rev(month(date, label = TRUE, abbr = FALSE)),
                   fill = PM10_cat
        )) +
            geom_tile(color = "black") +
            scale_fill_manual(name= NULL, values = category_colors, na.value = "black") +
            labs(title= "Particles smaller than 10 μm (PM10)",
                 x = "Day of Month", y = NULL) +
            theme_minimal() +
            theme(
                panel.grid = element_blank(),
                axis.text.x = element_text(size = 8, vjust = 0),
                axis.text.y = element_text(size = 10),
                axis.title.x.top = element_text(),
                axis.text.x.top = element_text(size = 8),
                axis.ticks.x.top = element_line(),
                axis.title.x = element_blank(),
                axis.text.x.bottom = element_blank(),
                axis.ticks.x.bottom = element_blank()
            ) +
            scale_x_continuous(position = "top", breaks = c(1, 7, 14, 21, 28))
    })
    
    output$calendar2 <- renderPlot({
        # Ensure inputs are available
        req(input$name_cal, input$year_cal)
        
        ggplot(madrid %>%
                   filter(name == input$name_cal,
                          year == input$year_cal),
               aes(x = day(date),
                   y = fct_rev(month(date, label = TRUE, abbr = FALSE)),
                   fill = O_3_cat
               )) +
            geom_tile(color = "black") +
            scale_fill_manual(name= NULL, values = category_colors, na.value = "black") +
            labs(title= "Ozone (O₃)",
                 x = "Day of Month", y = NULL) +
            theme_minimal() +
            theme(
                panel.grid = element_blank(),
                axis.text.x = element_text(size = 8, vjust = 0),
                axis.text.y = element_text(size = 10),
                axis.title.x.top = element_text(),
                axis.text.x.top = element_text(size = 8),
                axis.ticks.x.top = element_line(),
                axis.title.x = element_blank(),
                axis.text.x.bottom = element_blank(),
                axis.ticks.x.bottom = element_blank()
            ) +
            scale_x_continuous(position = "top", breaks = c(1, 7, 14, 21, 28))
    })
    output$calendar3 <- renderPlot({
        # Ensure inputs are available
        req(input$name_cal, input$year_cal)
        
        ggplot(madrid %>%
                   filter(name == input$name_cal,
                          year == input$year_cal),
               aes(x = day(date),
                   y = fct_rev(month(date, label = TRUE, abbr = FALSE)),
                   fill = NO_2_cat
               )) +
            geom_tile(color = "black") +
            scale_fill_manual(name= NULL, values = category_colors, na.value = "black") +
            labs(title= "Nitrogen dioxide (NO₂)",
                 x = "Day of Month", y = NULL) +
            theme_minimal() +
            theme(
                panel.grid = element_blank(),
                axis.text.x = element_text(size = 8, vjust = 0),
                axis.text.y = element_text(size = 10),
                axis.title.x.top = element_text(),
                axis.text.x.top = element_text(size = 8),
                axis.ticks.x.top = element_line(),
                axis.title.x = element_blank(),
                axis.text.x.bottom = element_blank(),
                axis.ticks.x.bottom = element_blank()
            ) +
            scale_x_continuous(position = "top", breaks = c(1, 7, 14, 21, 28))
    })
}

# Run App
shinyApp(ui, server)

#Reproducibility
# sink("session_info.txt")
# sessionInfo()
# sink()

########################### Shinnyapps.io Publish ############################
# library(rsconnect)
# rsconnect::setAccountInfo(name='',
#                           token='',
#                           secret='')
# 
# rsconnect::deployApp()

