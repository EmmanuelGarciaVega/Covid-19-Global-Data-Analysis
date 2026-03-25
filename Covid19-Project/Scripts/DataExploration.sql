/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows 
Functions, Aggregate Functions, Creating Views, 
Converting Data Types

Data Source:  ourworldindata.org
*/


Select *
From PortfolioProjectCovid..CovidDeaths
Where continent is not null--Excude data from some locations that are not countries (continents, world, etc)
order by 3,4

-- Adjusting column data type

ALTER TABLE CovidDeaths
ALTER COLUMN Date DATETIME;
ALTER TABLE CovidDeaths
ALTER COLUMN total_cases INT;
ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths INT;



-- Looking at the data we are going to work with

Select continent, location, date, total_cases, new_cases, total_deaths, new_deaths, population
From PortfolioProjectCovid..CovidDeaths
Where continent is not null --Excude some continet locations 
order by 1,2


-- Looking at Total Cases vs Total Deaths (in Costa Rica) to understant the data
-- Shows likelihood of dying if you contract covid in your country
Select 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(CAST(total_deaths AS float) / NULLIF(CAST(total_cases AS float), 0)) * 100 AS DeathPercentage
From PortfolioProjectCovid..CovidDeaths
Where location = 'Costa Rica'
order by 1,2



-- Looking at Total Cases vs Population (In Costa Rica)
-- Shows likelihood of infection in your country

Select 
	location, 
	date, 
	total_cases, 
	population, 
	(CAST(total_cases AS float) / NULLIF(CAST(population AS float), 0)) * 100 AS InfectionPercentage
From PortfolioProjectCovid..CovidDeaths
Where location = 'Costa Rica' 
order by 1,2


-- Looking at Countries with Highest Infection rate compared to Population

Select 
	location, 
	population, 
	Max(Total_cases) as HighestInfectionCount, 
	MAX(((CAST(total_cases AS float) / NULLIF(CAST(population AS float), 0))))*100 as PercentPopulationInfected
From PortfolioProjectCovid..CovidDeaths
Where continent is not null --Excude some continet locations 
Group by location, population
order by PercentPopulationInfected DESC


--Creating a view to see the percentage of population infected per country

CREATE OR ALTER VIEW PercentPopulationInfected AS
Select 
	location, 
	population, 
	Max(Total_cases) as HighestInfectionCount, 
	MAX(((CAST(total_cases AS float) / NULLIF(CAST(population AS float), 0))))*100 as PercentPopulationInfected
From PortfolioProjectCovid..CovidDeaths
Where continent is not null --Excude some continet locations 
Group by location, population



-- Checking at Countries with  highest Death Count 

Select 
	location,  
	Max(total_deaths) as HighestDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is not null --Excude some continet locations 
Group by location, population
order by HighestDeathCount DESC

--Creating a view to see the highest death count per country
Create or alter view HighestDeathCountPerCountry AS
Select 
	location,  
	Max(total_deaths) as HighestDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is not null --Excude some continet locations 
Group by location, population


-- Breaking it down by looking at Continents with  highest Death Count per population

Select 
	location, 
	Max(total_deaths) as HighestDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is null --Excude some continet locations 
Group by location
order by HighestDeathCount DESC

--Creating a view to see the highest death count per continent
Create or alter view HighestDeathCountPerContinent AS
Select 
	location, 
	Max(total_deaths) as HighestDeathCount
From PortfolioProjectCovid..CovidDeaths
Where (continent is null) 
	AND location not in ('World', 'European Union', 'International') --Excude some continet locations 
Group by location

--Global numbers

-- Total Cases, Total Deaths and Death Percentage per day Worldwide
Select 
	date, 
	SUM(Cast(New_cases as INT)) as total_cases, 
	SUM(Cast(New_deaths as INT)) as Total_deaths,
	(SUM(Cast(New_deaths as float))/nullif(SUM(Cast(New_cases as float)), 0))*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by date
Order by date


-- Total Cases, Total Deaths and Death Percentage  Worldwide

Select 
	SUM(Cast(New_cases as INT)) as total_cases, 
	SUM(Cast(New_deaths as INT)) as Total_deaths,
	(SUM(Cast(New_deaths as float))/nullif(SUM(Cast(New_cases as float)), 0))*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
Where continent is not null


-- Looking at total Population vs New Vaccinations per day in each country

Select 
	deaths.continent, 
	deaths.location, 
	deaths.date, 
	deaths.population, 
	vaccinations.new_vaccinations
From PortfolioProjectCovid..CovidDeaths deaths
Join PortfolioProjectCovid..CovidVaccinations vaccinations
	on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
Where deaths.continent is not null 
order by 2,3


-- Looking at total Population vs Total Vaccinations per day in each country
--CTE to calculate the rolling sum of vaccinations
WITH VaccinationRolling (Location, Date, population, NewVaccinations, TotalVaccinationsRolling) AS (
Select 
	deaths.location, 
	deaths.date, 
	deaths.population, 
	vaccinations.new_vaccinations,
	--Rolling agregation
	SUM(Convert(INT, vaccinations.new_vaccinations)) 
		OVER (PARTITION BY deaths.location ORDER BY deaths.date) as TotalVaccinationsRolling
From PortfolioProjectCovid..CovidDeaths deaths
Join PortfolioProjectCovid..CovidVaccinations vaccinations
	on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
Where deaths.continent is not null 
)

Select *, (TotalVaccinationsRolling / NULLIF(population, 0)) * 100 as PercentPopulationVaccinated
From VaccinationRolling
order by 1,2


--TEMP TABLE to see final percentage of population vaccinated per country (using the rolling sum of vaccinations)
--Drop the table if it already exists to allow for rerunning the script
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

--Create the Temp Table
CREATE TABLE #PercentPopulationVaccinated (
    Location nvarchar(255),
    Population numeric,
    New_vaccinations numeric,
    TotalVaccinationsRolling numeric
);

--Insert data into the Temp Table
INSERT INTO #PercentPopulationVaccinated
SELECT 
    deaths.location, 
    deaths.population, 
    vaccinations.new_vaccinations,
    SUM(CONVERT(BIGINT, vaccinations.new_vaccinations)) 
        OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as TotalVaccinationsRolling
FROM PortfolioProjectCovid..CovidDeaths deaths
JOIN PortfolioProjectCovid..CovidVaccinations vaccinations
    ON deaths.location = vaccinations.location
    AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL;

--Select the MAX percentage per country
SELECT 
    Location, 
    Population, 
    MAX(TotalVaccinationsRolling) as FinalTotalVaccinations,
    MAX((TotalVaccinationsRolling / NULLIF(Population, 0)) * 100) as FinalPercentPopulationVaccinated
FROM #PercentPopulationVaccinated
GROUP BY Location, Population
ORDER BY Location;

-- Create view of percentage of population vaccinated per country
CREATE OR ALTER VIEW PercentPopulationVaccinated AS
Select 
	deaths.location, 
	deaths.date, 
	deaths.population, 
	vaccinations.new_vaccinations,
	--Rolling agregation
	SUM(Convert(BIGINT, vaccinations.new_vaccinations)) 
		OVER (PARTITION BY deaths.location ORDER BY deaths.date) as TotalVaccinationsRolling,
	(CAST(SUM(Convert(BIGINT, vaccinations.new_vaccinations)) 
		OVER (PARTITION BY deaths.location ORDER BY deaths.date) AS float) / NULLIF(deaths.population, 0)) * 100 as PercentPopulationVaccinated
From PortfolioProjectCovid..CovidDeaths deaths
Join PortfolioProjectCovid..CovidVaccinations vaccinations
	on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
Where deaths.continent is not null 