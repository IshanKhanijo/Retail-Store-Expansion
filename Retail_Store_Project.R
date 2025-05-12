# CODE 1

# Load necessary libraries
library(sp)        # Spatial data
library(sf)        # Simple Features
library(spatstat)  # Spatial point pattern analysis
library(gstat)     # Geostatistical analysis
library(geoR)      # Geostatistical data analysis

# CODE 2
# Import the GeoJSON file
shops_data <- st_read("OpenStreetMap_Shops_for_Australia_and_Oceania.geojson")


# CODE 3
# Quick check of the data
summary(shops_data)
nrow(shops_data)

# Checking for missing values
sapply(shops_data, function(x) sum(is.na(x)))


# CODE 4
# Check unique country values
table(shops_data$addr_country, useNA = "ifany")

# Keep rows where country is Australia (AU) or missing (assume it's local)
australian_shops <- shops_data[is.na(shops_data$addr_country) | shops_data$addr_country == "AU", ]

# Confirm the row count
nrow(australian_shops)



# CODE 6
# Filter for common retail categories
retail_keywords <- c("supermarket", "convenience", "department_store", "clothing", "electronics", "retail", "store")
retail_shops <- australian_shops[grepl(paste(retail_keywords, collapse = "|"), australian_shops$shop, ignore.case = TRUE), ]

# Confirm the row count after filtering
nrow(retail_shops)


# Removing duplicates based on name and geometry
retail_shops <- retail_shops[!duplicated(retail_shops$name), ]

# Confirm the number of unique stores
nrow(retail_shops)


# Resetting row names for a cleaner dataframe
row.names(retail_shops) <- NULL

# Quick preview to confirm the reset
head(retail_shops)


# CODE 6
# Filter for valid Australian coordinates
retail_shops <- retail_shops[
  st_coordinates(retail_shops)[,2] >= -44 & 
    st_coordinates(retail_shops)[,2] <= -10 &
    st_coordinates(retail_shops)[,1] >= 112 & 
    st_coordinates(retail_shops)[,1] <= 154, 
]

# Confirm the number of rows after filtering
nrow(retail_shops)


# CODE 7

# Final duplicate removal based on name and geometry
retail_shops <- retail_shops[!duplicated(st_coordinates(retail_shops)), ]

# Confirm the number of unique stores
nrow(retail_shops)

# CODE 8

# Quick preview of the cleaned data
summary(retail_shops)
head(retail_shops)

# Save the cleaned data as a GeoJSON file for future use
st_write(retail_shops, "Cleaned_Retail_Shops_Australia.geojson")

# CODE 9

# Converting to SpatialPointsDataFrame
retail_shops_sp <- as(retail_shops, "Spatial")

# Quick check of the converted object
summary(retail_shops_sp)


# CODE 10

library(spatstat)

# CODE 11

# Extracting coordinates from the SpatialPointsDataFrame
coords <- coordinates(retail_shops_sp)

# Confirm the structure of the coordinates
head(coords)


# Define a bounding window for Australia
aus_window <- owin(xrange = c(112, 154), yrange = c(-44, -10))

# Create the ppp object
retail_shops_ppp <- ppp(x = coords[,1], y = coords[,2], window = aus_window)

# Quick check
summary(retail_shops_ppp)

# CODE 12
# Plotting the retail store locations
plot(retail_shops_ppp, main = "Retail Store Locations in Australia", pch = 20, cex = 0.5)

# Adding title and labels for clarity
title(main = "Retail Store Locations in Australia", xlab = "Longitude", ylab = "Latitude")


# CODE 13
# Estimating spatial intensity
intensity_map <- density(retail_shops_ppp, sigma = 0.5)
# Plotting the intensity map
plot(intensity_map, main = "Retail Store Density in Australia")
plot(retail_shops_ppp, pch = 20, cex = 0.3, col = "black", add = TRUE)

# CODE 14
# Re-estimating with a smaller bandwidth for finer details
intensity_map_fine <- density(retail_shops_ppp, sigma = 0.3)

# Plotting the refined intensity map
plot(intensity_map_fine, main = "Refined Retail Store Density in Australia", col = rev(heat.colors(256)))
plot(retail_shops_ppp, pch = 20, cex = 0.2, col = "black", add = TRUE)



# CODE 15
# Calculating Ripley's K-function
K_ripley <- Kest(retail_shops_ppp, correction = "Ripley")
# Plotting the K-function
plot(K_ripley, main = "Ripley's K-Function for Retail Stores in Australia", legend = FALSE)


# Calculating the L-function
L_ripley <- Lest(retail_shops_ppp, correction = "Ripley")
# Plotting the L-function
plot(L_ripley, main = "Ripley's L-Function for Retail Stores in Australia", legend = FALSE)



# CODE 16
# KDE with finer resolution
fine_density <- density(retail_shops_ppp, sigma = 0.15)
# Plotting the refined density map
plot(fine_density, main = "Refined Hotspot Map for Retail Stores in Australia", col = rev(heat.colors(256)))
plot(retail_shops_ppp, pch = 20, cex = 0.2, col = "black", add = TRUE)



# CODE 17
# Extracting coordinates from the high-density regions
high_density_threshold <- quantile(fine_density$v, 0.95)
# Converting the pixel image to points based on the threshold
hotspots <- as.data.frame(fine_density)
hotspots <- hotspots[hotspots$val >= high_density_threshold, ]
# Quick preview of the extracted hotspots
head(hotspots)
nrow(hotspots)



# CODE 18
# Plotting the original store distribution
plot(fine_density, main = "Retail Store Hotspots in Australia", col = rev(heat.colors(256)))
plot(retail_shops_ppp, pch = 20, cex = 0.2, col = "black", add = TRUE)
# Adding the extracted hotspots
points(hotspots$x, hotspots$y, col = "red", pch = 3, cex = 0.5)


# CODE 19
# Creating a SpatialPointsDataFrame for hotspots
library(sp)
coordinates(hotspots) <- ~x+y
proj4string(hotspots) <- CRS("+proj=longlat +datum=WGS84")
# Saving the hotspots as a GeoJSON file for future analysis
library(sf)
hotspots_sf <- st_as_sf(hotspots)
st_write(hotspots_sf, "Retail_Store_Hotspots_Australia.geojson")



#Section 2: Market Reach and Catchment Area Analysis 
# cODE 20
# Creating 10 km buffer zones around each hotspot
hotspot_buffers <- st_buffer(hotspots_sf, dist = 10000)  # 10,000 meters = 10 km
# Plotting the buffer zones
plot(hotspot_buffers, col = rgb(1, 0, 0, 0.2), main = "Catchment Areas (10 km) Around Retail Hotspots")
plot(st_geometry(hotspots_sf), pch = 20, cex = 0.2, col = "black", add = TRUE)


# CODE 21
# Flattening and removing empty geometries
overlapping_geoms <- st_cast(overlapping_areas, "POLYGON")
overlapping_geoms <- st_make_valid(overlapping_geoms)
overlapping_geoms <- overlapping_geoms[!st_is_empty(overlapping_geoms), ]
# Plotting the cleaned overlapping catchment areas
plot(st_geometry(overlapping_geoms), col = rgb(1, 0, 0, 0.4), main = "Overlapping Catchment Areas (10 km)")
plot(st_geometry(hotspots_sf), pch = 20, cex = 0.2, col = "black", add = TRUE)



# Preparing for Market Potential Analysis
# code 22
# Extracting the centroids of the buffer zones for better visualization
hotspot_centroids <- st_centroid(hotspot_buffers)

# Plotting the centroids
plot(hotspot_buffers, col = rgb(0.8, 0.8, 0.8, 0.5), main = "Retail Store Catchment Areas (10 km) with Centroids")
plot(st_geometry(hotspot_centroids), pch = 20, col = "red", add = TRUE)



# 23
# Estimating market potential based on density
hotspot_buffers$market_potential <- st_area(hotspot_buffers) / 1e6  # Convert to square kilometers
# Visualizing the market potential
plot(hotspot_buffers["market_potential"], main = "Market Potential by Catchment Area (sq km)")
plot(st_geometry(hotspot_centroids), pch = 20, col = "red", add = TRUE)


# 24
# Extracting centroid coordinates for potential data merging
centroids_coords <- st_coordinates(hotspot_centroids)
centroids_df <- data.frame(ID = seq_len(nrow(centroids_coords)),
                           Longitude = centroids_coords[, 1],
                           Latitude = centroids_coords[, 2])

# Quick preview
head(centroids_df)



# 25
library(readxl)

# Loading population and income data
population_data <- read_excel("14100DO0001_2011-24.xlsx", sheet = 1)
income_data <- read_excel("14100DO0002_2011-24.xlsx", sheet = 1)

# Quick preview
head(population_data)
head(income_data)

library(readxl)

# Listing all sheets in the population and income files
population_sheets <- excel_sheets("14100DO0001_2011-24.xlsx")
income_sheets <- excel_sheets("14100DO0002_2011-24.xlsx")

# Print the sheet names for reference
print(population_sheets)
print(income_sheets)


library(readxl)

# Loading the relevant tables
population_data <- read_excel("14100DO0001_2011-24.xlsx", sheet = "Table 1", skip = 6)
income_data <- read_excel("14100DO0002_2011-24.xlsx", sheet = "Table 1", skip = 6)

# Quick preview of the data
head(population_data)
head(income_data)


# Checking the structure and column names
str(population_data)
str(income_data)

# Previewing the first few rows
head(population_data)
head(income_data)

# Printing the column names for easier selection
colnames(population_data)
colnames(income_data)



# Extracting key columns from population data
population_relevant <- population_data[, c("Code", "Label", "Year", 
                                           "Estimated resident population (no.)", 
                                           "Population density (persons/km2)", 
                                           "Working age population (aged 15-64 years) (no.)")]

# Extracting key columns from income data
income_relevant <- income_data[, c("Code", "Label", "Year", 
                                   "Employed (no.)...97", 
                                   "Total applicable population aged 25-64 years (no.)", 
                                   "Median age - persons (years)")]

# Renaming columns for consistency
colnames(income_relevant) <- c("Code", "Label", "Year", "Employed (no.)", 
                               "Total Population Aged 25-64 (no.)", "Median Age (years)")

# Quick preview
head(population_relevant)
head(income_relevant)



# Removing rows with missing values
population_cleaned <- na.omit(population_relevant)
income_cleaned <- na.omit(income_relevant)

# Merging the cleaned data
market_potential_data <- merge(population_cleaned, income_cleaned, by = c("Code", "Label", "Year"))

# Quick preview to confirm the merge
head(market_potential_data)
summary(market_potential_data)





# Selecting the latest available year for a consistent snapshot
latest_year <- max(market_potential_data$Year)

# Filtering the data to the latest year
market_potential_latest <- market_potential_data[market_potential_data$Year == latest_year, ]

# Dropping the 'Year' column as it's now uniform
market_potential_latest$Year <- NULL

# Quick preview
head(market_potential_latest)
summary(market_potential_latest)



# Rebuilding the centroids data from the extracted hotspot coordinates
centroids_df <- data.frame(
  ID = 1:nrow(hotspots),
  Longitude = hotspots$x,
  Latitude = hotspots$y
)

# Merging with the latest market potential data
centroids_with_potential <- merge(centroids_df, market_potential_latest, by.x = "ID", by.y = "Code", all.x = TRUE)

# Quick preview
head(centroids_with_potential)
summary(centroids_with_potential)


# Assuming your centroids data is already loaded as 'centroids_df'
# Merging with the latest market potential data
centroids_with_potential <- merge(centroids_df, market_potential_latest, by.x = "ID", by.y = "Code", all.x = TRUE)

# Quick preview of the merged data
head(centroids_with_potential)
summary(centroids_with_potential)




# Converting relevant columns to numeric
centroids_with_potential$`Estimated resident population (no.)` <- as.numeric(centroids_with_potential$`Estimated resident population (no.)`)
centroids_with_potential$`Population density (persons/km2)` <- as.numeric(centroids_with_potential$`Population density (persons/km2)`)
centroids_with_potential$`Working age population (aged 15-64 years) (no.)` <- as.numeric(centroids_with_potential$`Working age population (aged 15-64 years) (no.)`)
centroids_with_potential$`Employed (no.)` <- as.numeric(centroids_with_potential$`Employed (no.)`)

# Recalculating the MPS
centroids_with_potential$MPS <- with(centroids_with_potential, 
                                     `Estimated resident population (no.)` * 
                                       `Population density (persons/km2)` * 
                                       `Working age population (aged 15-64 years) (no.)` * 
                                       `Employed (no.)`)

# Quick preview
head(centroids_with_potential[, c("ID", "Longitude", "Latitude", "MPS")])
summary(centroids_with_potential$MPS)




# Normalizing the MPS values to a 0-100 scale
centroids_with_potential$MPS_normalized <- scale(centroids_with_potential$MPS, center = FALSE, scale = max(centroids_with_potential$MPS, na.rm = TRUE)) * 100

# Quick preview to confirm the normalization
head(centroids_with_potential[, c("ID", "Longitude", "Latitude", "MPS", "MPS_normalized")])
summary(centroids_with_potential$MPS_normalized)



# Loading required libraries
library(sf)
library(ggplot2)

# Converting to sf object for mapping
centroids_sf <- st_as_sf(centroids_with_potential, coords = c("Longitude", "Latitude"), crs = 4326)

# Plotting the MPS scores
ggplot(data = centroids_sf) +
  geom_sf(aes(color = MPS_normalized), size = 2, alpha = 0.7) +
  scale_color_gradient(low = "blue", high = "red") +
  labs(title = "Market Potential Scores (Normalized)", color = "MPS (0-100)") +
  theme_minimal()


# Check and set the correct CRS
st_crs(centroids_sf) <- 4326

# Replot without aggressive filtering
ggplot(data = centroids_sf) +
  geom_sf(aes(color = MPS_normalized), size = 1.5, alpha = 0.8) +
  scale_color_gradient(low = "lightblue", high = "darkred") +
  labs(title = "High Market Potential Zones (MPS > 10)", color = "MPS (0-100)") +
  theme_minimal()



# Extracting the top 10 high-potential zones
top_zones <- centroids_with_potential[order(-centroids_with_potential$MPS_normalized), ][1:10, ]

# Displaying the top 10 zones
print(top_zones[, c("ID", "Longitude", "Latitude", "MPS_normalized")])
summary(top_zones$MPS_normalized)




# Plotting the top 10 high-potential zones
ggplot(data = centroids_sf) +
  geom_sf(aes(color = MPS_normalized), size = 1.5, alpha = 0.8) +
  geom_sf(data = centroids_sf[centroids_sf$ID %in% top_zones$ID, ], color = "darkred", size = 3, alpha = 0.9) +
  scale_color_gradient(low = "lightblue", high = "darkred") +
  labs(title = "Top 10 High Market Potential Zones", color = "MPS (0-100)") +
  theme_minimal()




# Extracting detailed information for the top 10 zones
top_zone_details <- centroids_with_potential[centroids_with_potential$ID %in% top_zones$ID, ]

# Displaying the detailed information
print(top_zone_details[, c("ID", "Longitude", "Latitude", 
                           "Estimated resident population (no.)", 
                           "Population density (persons/km2)", 
                           "Working age population (aged 15-64 years) (no.)", 
                           "Employed (no.)", "MPS", "MPS_normalized")])

summary(top_zone_details)



# Extracting high-potential zones with low population density (ideal for new market entry)
high_potential_low_density <- top_zone_details[
  top_zone_details$`Population density (persons/km2)` < 1000 & 
    top_zone_details$MPS_normalized > 10, ]

# Displaying the results
print(high_potential_low_density[, c("ID", "Longitude", "Latitude", 
                                     "Estimated resident population (no.)", 
                                     "Population density (persons/km2)", 
                                     "Working age population (aged 15-64 years) (no.)", 
                                     "Employed (no.)", "MPS", "MPS_normalized")])

summary(high_potential_low_density)



# Plotting high-potential, low-density zones
ggplot(data = centroids_sf) +
  geom_sf(aes(color = MPS_normalized), size = 1.5, alpha = 0.7) +
  geom_sf(data = centroids_sf[centroids_sf$ID %in% high_potential_low_density$ID, ], 
          color = "darkgreen", size = 3, alpha = 0.9) +
  scale_color_gradient(low = "lightblue", high = "darkred") +
  labs(title = "High-Potential, Low-Density Zones", color = "MPS (0-100)") +
  theme_minimal()









