SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[population]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
      ,[total_tests]
  FROM [PortfolioProjectSQLDataExploration].[dbo].[COVID Deaths1]

  -- SELECT DATA USED INITIALLY 
  SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM PortfolioProjectSQLDataExploration..[COVID Deaths1]
  ORDER BY 1,2

  -- TOTAL CASES VS TOTAL DEATHS
  -- PERCENTAGE OF DEATHS IN THE US OF THOSE WHO CONTRACTED COVID

  SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  FROM PortfolioProjectSQLDataExploration..[COVID Deaths1]
  WHERE location like '%States%'
  ORDER BY 1,2

  -- TOTAL CASES VS POPULATION 
  -- PERCENTAGE OF POPULATION THAT CONTRACTED COVID IN THE US
  SELECT location, date, population, total_cases, (total_deaths/population)*100 as PercentagePopulationAffected
  FROM PortfolioProjectSQLDataExploration..[COVID Deaths1]
  WHERE location like '%States%'
  ORDER BY 1,2 

  -- COUNTRIES OF HIGHEST INFECTION RATE VS POPULATION 
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProjectSQLDataExploration..[COVID Deaths1]
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc

-- COUNTRIES W/ HIGHEST DEATH RATE VS POPULATION
SELECT location, MAX(total_deaths)as TotalDeathCount
FROM PortfolioProjectSQLDataExploration..[COVID Deaths1]
GROUP BY location
ORDER BY TotalDeathCount desc

-- VIEWING BY CONTINENT
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProjectSQLDataExploration..[COVID Deaths1]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- CONTINENTS W/ HIGHEST DEATH COUNT
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProjectSQLDataExploration..[COVID Deaths1]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjectSQLDataExploration..[COVID Deaths1]
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- TOTAL POPULATION VS VACCINATION
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProjectSQLDataExploration..[COVID Deaths1] DEA
JOIN PortfolioProjectSQLDataExploration..[COVID Vaccinations] VAC
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProjectSQLDataExploration..[COVID Deaths1] DEA
JOIN PortfolioProjectSQLDataExploration..[COVID Vaccinations] VAC
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not null
)
SELECT *, (PeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PERCENTPOPULATIONVACCINATED
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProjectSQLDataExploration..[COVID Deaths1] DEA
JOIN PortfolioProjectSQLDataExploration..[COVID Vaccinations] VAC
  ON dea.location = vac.location
  AND dea.date = vac.date 
--WHERE dea.continent is not null

SELECT *, (PeopleVaccinated/Population)*100
FROM #PERCENTPOPULATIONVACCINATED


-- CREATING VIEW TO STORE DATA FOR LTR VISIUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProjectSQLDataExploration..[COVID Deaths1] DEA
JOIN PortfolioProjectSQLDataExploration..[COVID Vaccinations] VAC
  ON dea.location = vac.location
  AND dea.date = vac.date 
WHERE dea.continent is not null

SELECT *, (PeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

SELECT *
FROM PercentPopulationVaccinated