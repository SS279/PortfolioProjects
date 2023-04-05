Select Location,date,total_cases,new_cases,total_deaths,population from [Portfolio Projects]..CovidDeaths
Order BY 1,2;

 -- Looking at Total cases vs Total Deaths
 -- Shows the likelihood of dying if you contract covid in UK
Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from [Portfolio Projects]..CovidDeaths
where location like '%United Kingdom%'
Order BY 1,2;

 -- Looking at Total cases vs Population
 -- Shows what percentage of population got covid in UK
Select Location,date,total_cases,population, (total_cases/population)* 100 as DeathPercentage
from [Portfolio Projects]..CovidDeaths
where location like '%United Kingdom%'
Order BY 1,2;

-- Countries with highest infected rate compared to population

Select Location,population,MAX(total_cases) as HighestInfectionRate, Max((total_cases/population))* 100 as PercentPopulaaitonInfected
from [Portfolio Projects]..CovidDeaths
where continent is not null
GROUP BY Location,population
Order BY PercentPopulaaitonInfected DESC;

-- Countries with highest death count per population

Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Projects]..CovidDeaths
where continent is not null
GROUP BY Location
Order BY TotalDeathCount DESC;


-- LET'S BREAK THINGS BY CONTINENT

-- Showing the continents with highest death count

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Projects]..CovidDeaths
where continent is not null
GROUP BY continent
Order BY TotalDeathCount DESC;


-- GLOBAL NUMBERS

-- Total numbers based on date
Select date,SUM(new_cases) as Total_CASES,SUM(CAST(new_deaths as int)) as TOTAL_DEATHS, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Projects]..CovidDeaths
where continent is not null
Group BY date
Order BY 1,2;

-- Total numbers
Select SUM(new_cases) as Total_CASES,SUM(CAST(new_deaths as int)) as TOTAL_DEATHS, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Projects]..CovidDeaths
where continent is not null
Order BY 1,2;



SELECT Deaths.continent,Deaths.location,Deaths.date, Deaths.population, Vaccinations.new_vaccinations,
SUM(CONVERT(int,Vaccinations.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location,Deaths.date) AS RollingPeopleVaccinated
FROM [Portfolio Projects]..CovidDeaths as Deaths
JOIN [Portfolio Projects]..CovidVaccinations AS Vaccinations
ON Deaths.location = Vaccinations.location and Deaths.date = Vaccinations.date
where Deaths.continent is not null
ORDER BY 2,3;

-- USE CTE

-- % of people got vaccinated in each location

WITH PopvsVac (Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
AS
(SELECT Deaths.continent,Deaths.location,Deaths.date, Deaths.population, Vaccinations.new_vaccinations,
SUM(CONVERT(int,Vaccinations.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location,Deaths.date) AS RollingPeopleVaccinated
FROM [Portfolio Projects]..CovidDeaths as Deaths
JOIN [Portfolio Projects]..CovidVaccinations AS Vaccinations
ON Deaths.location = Vaccinations.location and Deaths.date = Vaccinations.date
where Deaths.continent is not null)
SELECT *,(RollingPeopleVaccinated/Population)*100 AS PercentageofPopVaccinated FROM PopvsVac;

-- Use Temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Deaths.continent,Deaths.location,Deaths.date, Deaths.population, Vaccinations.new_vaccinations,
SUM(CONVERT(int,Vaccinations.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location,Deaths.date) AS RollingPeopleVaccinated
FROM [Portfolio Projects]..CovidDeaths as Deaths
JOIN [Portfolio Projects]..CovidVaccinations AS Vaccinations
ON Deaths.location = Vaccinations.location and Deaths.date = Vaccinations.date
where Deaths.continent is not null

SELECT *,(RollingPeopleVaccinated/Population)*100 AS PercentageofPopVaccinated FROM #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT Deaths.continent,Deaths.location,Deaths.date, Deaths.population, Vaccinations.new_vaccinations,
SUM(CONVERT(int,Vaccinations.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location,Deaths.date) AS RollingPeopleVaccinated
FROM [Portfolio Projects]..CovidDeaths as Deaths
JOIN [Portfolio Projects]..CovidVaccinations AS Vaccinations
ON Deaths.location = Vaccinations.location and Deaths.date = Vaccinations.date
where Deaths.continent is not null;

SELECT * FROM PercentPopulationVaccinated;