

SELECT *
FROM PortfolioProject1..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select data that we area going to use
SELECT location, date,total_cases,new_cases,total_deaths, population
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2

--Looking at Total_Cases VS Total_deaths
SELECT location, date,total_cases,total_deaths
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2

----Altering Column Type(did not work, need to create new table)
--ALTER TABLE dbo.CovidDeaths ALTER COLUMN date datetime

-- Looking at Total Cases VS Total Deaths (have to cast one of the column as BIGint/BIGint does not yield float)
--Likelihood of death if contracted covid19
SELECT location, date, total_cases,total_deaths,(CAST(total_deaths AS FLOAT)/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%malay%'
ORDER BY 1,2


--Looking at Total Cases VS Population
--Shows what percentage of population got covid
SELECT location, date,population, total_cases,(CAST(total_cases AS FLOAT)/population)*100 AS CasesPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%malay%'
ORDER BY 1,2

--Countries with the highest infection rate compared to population
SELECT location,population, MAX(total_cases) AS HighestInfectionCount,MAX((CAST(total_cases AS FLOAT)/population))*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 4 DESC
OFFSET 0 ROWS 
FETCH NEXT 10 ROWS ONLY

--Showing Countries with the highest death count per population
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--LETS BREAK THINGS DOWN BY CONTINENT (This is right way with Continent!!)
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject1..CovidDeaths
--WHERE location LIKE '%malay%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1


--looking at Total Population VS Vaccination
SELECT dea.continent, dea.location, dea.date,dea. population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USING CTE

WITH PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date,dea. population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (CAST(RollingPeopleVaccinated AS FLOAT)/Population)*100
FROM PopvsVac



--USING TempTable
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea. population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (CAST(RollingPeopleVaccinated AS FLOAT)/Population)*100
FROM #PercentPopulationVaccinated




--Creating View to store data for later visualisation

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date,dea. population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

CREATE VIEW HighestDeathCountPerContinent AS
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NULL
GROUP BY location

SELECT *
FROM PercentPopulationVaccinated
