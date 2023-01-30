SELECT location, date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS "Death Percentage"
FROM PortfolioProject..CovidDeaths
WHERE location like '%states' AND continent is not null
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date, total_cases, population, ((total_cases/population)*100) AS "Covid Percentage" 
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states'
WHERE continent is not null
ORDER BY 1,2;

-- Looking at countries with higest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS "Highest Infection Count", ((MAX(total_cases)/population)*100) AS "Infection Rate"
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY population, location
ORDER BY [Infection Rate] DESC;


-- Showing the countries with Highest Death Count per Population
 -- Casted to bignint because it was varChar()

SELECT location, MAX(cast(total_deaths as bigint)) AS "Total Death Counts"
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY [Total Death Counts] desc;


-- Let's break it by continent
SELECT continent, MAX(cast(total_deaths as bigint)) AS "Total Death Counts"
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY [Total Death Counts] desc;


-- Let's break it by continent
SELECT location, MAX(cast(total_deaths as bigint)) AS "Total Death Counts"
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY [Total Death Counts] desc;




-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as "Total Cases", SUM(cast(new_deaths as bigint)) as "Total Deaths", (SUM(cast(new_deaths as bigint))/SUM(new_cases))*100 as  "Death Percentage"
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
Order by 1,2


SELECT SUM(new_cases) as "Total Cases", SUM(cast(new_deaths as bigint)) as "Total Deaths", (SUM(cast(new_deaths as bigint))/SUM(new_cases))*100 as  "Death Percentage"
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 1,2


--Looking at total population vs vacinnated population

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
Order by 1,2, 3



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by vac.location ORDER BY dea.location, dea.date) as "Rolling People Vaccinated"
 -- , (
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
Order by 1,2, 3



-- Use CTE (Common Table Expression), number of column  should be same both in CTE and ..

WITH PopvsVac (Continent, location, date, population, new_vaccinations , RollingPeopleVaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by vac.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 -- , (
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
--Order by 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac;




-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by vac.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 -- , (
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
--Order by 2, 3
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated;





-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by vac.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null;