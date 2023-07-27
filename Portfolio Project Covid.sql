

USE [Portfolio Project]
SELECT * FROM [Portfolio Project]..coviddeaths$

--Changing Data types

ALTER TABLE [Portfolio Project]..coviddeaths$
ALTER COLUMN total_cases FLOAT

ALTER TABLE [Portfolio Project]..coviddeaths$
ALTER COLUMN total_deaths FLOAT

--Looking at Total deaths VS Total cases

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as 'DeathPercentages'
FROM [Portfolio Project]..coviddeaths$
ORDER BY 1,2

--Looking for DeathPercentages of US

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as 'DeathPercentages'
FROM [Portfolio Project]..coviddeaths$
WHERE location like '%states%' and continent is not null
ORDER BY 3

--Looking at Total Cases VS Population
--Percentages of population got covid
SELECT location,date,total_cases,population,(total_cases/population)*100 as 'CovidPercentages'
FROM [Portfolio Project]..coviddeaths$
WHERE location like '%states%'
ORDER BY 3

--Looking at country has highest infection rate compared to population
SELECT location,population,MAX(total_cases) as 'HighestInfectionCount',MAX((total_cases/population)*100) as 'CovidPercentages'
FROM [Portfolio Project]..coviddeaths$
WHERE Continent is not null
Group By location, population
ORDER BY 4 desc

--Looking at country has highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as 'TotalDeathsCount'
FROM [Portfolio Project]..coviddeaths$
WHERE Continent is not null
Group By location
ORDER BY Totaldeathscount DESC

--Looking at continent has highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as 'TotalDeathsCount'
FROM [Portfolio Project]..coviddeaths$
WHERE Continent is null
Group By location
ORDER BY Totaldeathscount DESC

--Global Numbers
Select SUM(new_cases) as TotalCases, SUM(new_deaths) as Totaldeaths,
CASE WHEN SUM(new_cases) = 0 THEN 0 ELSE (SUM(new_deaths)/SUM(new_cases))END*100 AS deathpercentages
FROM [Portfolio Project]..coviddeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1

--Looking at Total Population vs Vaccinations
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
, SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by d.location ORDER by d.location,d.date) as AccumulatedPeopleVaccined
FROM [Portfolio Project]..coviddeaths$ d
JOIN [Portfolio Project]..covidvaccine$ v
ON d.date = v.date and d.location = v.location
WHERE d.continent is not null and v.new_vaccinations is not null
order by 2,3 

-- Use CTE 

With popvsvac (Continent, Location, Date,Population, new_vaccinations, AccumulatedPeopleVaccined)
as
(
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
, SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by d.location ORDER by d.location,d.date) as AccumulatedPeopleVaccined
FROM [Portfolio Project]..coviddeaths$ d
JOIN [Portfolio Project]..covidvaccine$ v
ON d.date = v.date and d.location = v.location
WHERE d.continent is not null and v.new_vaccinations is not null
--order by 2,3 
)

SELECT *,(AccumulatedPeopleVaccined/Population)*100 as TotalAccumulated
FROM popvsvac

-- Use Temp Table
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
AccumulatedPeopleVaccined numeric,
)

Insert into #PercentagePopulationVaccinated
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
, SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by d.location ORDER by d.location,d.date) as AccumulatedPeopleVaccined
FROM [Portfolio Project]..coviddeaths$ d
JOIN [Portfolio Project]..covidvaccine$ v
ON d.date = v.date and d.location = v.location
WHERE d.continent is not null and v.new_vaccinations is not null

SELECT *, (AccumulatedPeopleVaccined/Population)*100 as TotalAccumulatedPopulation
FROM #PercentagePopulationVaccinated

--CREATING VIEW TO STORE DATA

CREATE VIEW PercentagePopulationVaccinated as 
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
, SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by d.location ORDER by d.location,d.date) as AccumulatedPeopleVaccined
FROM [Portfolio Project]..coviddeaths$ d
JOIN [Portfolio Project]..covidvaccine$ v
ON d.date = v.date and d.location = v.location
WHERE d.continent is not null and v.new_vaccinations is not null

SELECT *
FROM PercentagePopulationVaccinated