This data visualization project is an assignment for the course Visualisation in Data Science 2024-2025 at Hasselt University. All authors (Lisa Angel Akiteng, Luis César Herrera Paltán , Nele Verhulst) are current students at Hasselt University.

The project uses the dataset ‘Air Quality in Madrid (2001-2018)’ that is freely available on Kaggle: https://www.kaggle.com/datasets/decide-soluciones/air-quality-madrid

The aim of the assignment was to visualize data on air quality in Madrid between 2001 and 2018 to make the information accessible for its population. Visualizations focus on three pollutants with public health implications that are included in the European air quality index: concentrations of particles smaller than 10 μm (PM10), nitrogen dioxide (NO2) and ozone (O3). We selected these three pollutants because of their importance for human health according to the World Health Organization and the European Union and by taking into account the availability of data. Three questions guided the visualization: 

Question 1: How has pollution in Madrid evolved between 2001 and 2018?
Question 2. Which periods of the year are the best and worst in terms of pollution?
Question 3. Which are the areas of Madrid where pollution is highest / lowest in 2018?

To reproduce our solution from the ground up we strongly suggest you create a new R project in a new directory to simplify pathing and copy the folder structure in G2s Dashboard.zip.

raw_data: stores downloaded kaggle data (e.g. station.csv and madrid_2001.csv, …, madrid_2018.csv)
processed_data: ProcessData.R cleans and merges raw data files and stores them in this directory as madrid.csv and stations.csv.
app.R: This is our main script, it encapsulates both ‘ui’ & ‘server’ sections of our shiny app, and produces the dashboard. Before generating the shiny app, It runs ImportData.R, Map.R, Barplot.R and Calendar.R scripts to load all relevant objects in our environment.
ImportData.R: Imports processed data (csv files) from the processed_data file. 
Map.R: Produces graphs used in the dashboard’s ‘Pollution and air quality’ tab.
Barplot.R: Produces graphs used in the dashboard’s ‘Pollution yearly evolution’ tab.
Calendar.R: Produces graphs used in the dashboard’s ‘Pollutants daily evolution’ tab.

Our dashboard is published and can be accessed using the following link:
https://lchp.shinyapps.io/g2s_dashboard/

It was published using a free account on shinyapps.io This can be done following the commented lines at the bottom of out apps.R script using valid credentials.

For information on reproducibility please refer to session_info.txt
