# Retail Store Market Expansion

## Project Overview
This project uses spatial analysis to identify high-potential retail zones in Australia. It includes data cleaning, hotspot detection, market potential scoring, and opportunity mapping to guide strategic business decisions.

---

## Project Workflow
1. **Data Collection and Cleaning:**  
   - Removed duplicates, validated coordinates, and filtered for Australian locations.  
   - Used data from [OpenStreetMap](https://onemap-esri.hub.arcgis.com/datasets/988071da24954be5b250a5d2a6bc6cab_0/about) and [Australian Bureau of Statistics (ABS)](https://www.abs.gov.au/methodologies/data-region-methodology/2011-24#data-downloads).  

2. **Hotspot Detection:**  
   - Identified high-density retail clusters in major cities like **Sydney, Melbourne, and Brisbane** using spatial density analysis.  

3. **Catchment Analysis:**  
   - Created **10 km buffer zones** around hotspots to understand store reach and reduce overlap.  

4. **Market Potential Scoring (MPS):**  
   - Calculated **Market Potential Scores** based on factors like **population, employment, working-age population,** and **spending power**.  

5. **Opportunity Mapping:**  
   - Identified **high-MPS, low-density** zones ideal for **new store launches** or regional hubs.  

---

## Visuals
Below are some of the key visuals generated in this project:

### Retail Store Locations in Australia  
![Retail Store Locations](./4a81df8d-71b9-4dc1-88aa-7609180f0730.png)  

### Market Potential by Catchment Area (sq km)  
![Market Potential](./98c4db7c-4229-459a-ab34-ddde3b79634a.png)  

### Top 10 High Market Potential Zones  
![Top 10 High MPS Zones](./460d715a-0853-433d-a04d-ae4f9e5ceae1.png)  

### Retail Store Hotspots in Australia  
![Retail Store Hotspots](./bef3d97d-272e-4a1f-8416-e468b612ce60.png)  

### Catchment Areas (10 km) Around Retail Hotspots  
![Catchment Areas](./ce4f1e3e-5c8f-44f3-9728-576a607721c4.png)  

### Market Potential Scores (Normalized)  
![MPS Normalized](./MPS_nornalised.png)  


---

## How to Use
1. Clone this repository.  
2. Run the **Retail_Store_Project.R** file in **RStudio** or **R**.  
3. Make sure to install the required libraries: **sp, sf, spatstat, gstat, geoR**.  

---

## Data Sources
- **Retail Shop Locations:** [OpenStreetMap Shops for Australia and Oceania (ArcGIS)(https://onemapesri.hub.arcgis.com/datasets/988071da24954be5b250a5d2a6bc6cab_0/about)  
- **Demographic Data:** [Australian Bureau of Statistics (ABS)](https://www.abs.gov.au/methodologies/data-region-methodology/2011-24#data-downloads)  

---

## License
This project is licensed under the MIT License - see the **LICENSE** file for details.

---

## Contact
Feel free to connect if you have questions or want to collaborate on similar projects.
LinkedIn: www.linkedin.com/in/ishankhanijo

---
