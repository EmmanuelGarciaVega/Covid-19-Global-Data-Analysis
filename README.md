# Covid-19 Global Data Analysis & Visualization

## Project Overview
This project explores global COVID-19 data to identify trends in infection rates, death percentages, and vaccination progress across different countries and continents. The analysis transitions from raw data exploration in SQL to structured queries optimized for a visual dashboard in Tableau.

## Dashboard Link
**[View Interactive Tableau Dashboard](https://public.tableau.com/app/profile/emmanuel.garcia2166/viz/DashboardProjectCovid/Dashboard1?publish=yes)**

---

## Technical Skills Demonstrated
* **Advanced SQL Techniques:** Joins, CTEs (Common Table Expressions), Temp Tables, Window Functions, Aggregate Functions, and Creating Views.
* **Data Cleaning:** Data type conversion and handling null values for consistent reporting.
* **Data Visualization:** Designing interactive dashboards in Tableau to communicate complex data trends.

## Data Source
The data used in this project is sourced from [Our World in Data](https://ourworldindata.org/covid-deaths).

---

## Project Structure

### 1. Data Exploration (`/Scripts/DataExploration.sql`)
Initial deep dive into the dataset to understand the relationship between cases, deaths, and population.
* **Death Likelihood:** Analysis of total cases vs. deaths in specific locations (e.g., Costa Rica).
* **Infection Rates:** Identifying which countries have the highest infection rates compared to their population.
* **Vaccination Progress:** Using **Window Functions** and **CTEs** to calculate a rolling count of people vaccinated per country.

### 2. Tableau Queries (`/Scripts/TableuQuearies.sql`)
Refined SQL queries specifically formatted for data visualization:
* **Global Totals:** Aggregate case and death counts worldwide.
* **Continental Breakdown:** Summarizing total deaths by continent for geographic comparison.
* **Geographical Mapping:** Preparing infection rate data for map visualizations.
* **Time Series:** Tracking the percentage of population infected over time.

---

## Key Insights
* **Rolling Aggregations:** By using `SUM() OVER (PARTITION BY...)`, we can see the real-time progression of vaccination efforts across borders.
* **Population Impact:** The analysis highlights a significant variance in infection percentages depending on population density and reporting accuracy.
* **Global Trends:** Clear visualization of how different continents managed infection peaks and death rates throughout the pandemic.

---

## How to Run
1.  Import the datasets provided in the `/Data` folder into your SQL Server instance.
2.  Execute the scripts in the `/Scripts` folder to generate the necessary views and filtered tables.
3.  Use the provided link to interact with the dashboard.
