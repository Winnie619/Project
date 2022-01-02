
SELECT *
FROM Project..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- Looking at Total cases vs Total Deaths
ALTER TABLE CovidDeaths ALTER COLUMN total_deaths FLOAT
ALTER TABLE CovidDeaths ALTER COLUMN total_cases FLOAT
-- Shows likelihood od dying if you get covid in Canada
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project..CovidDeaths
WHERE location like '%Canada%'
and continent is not null
ORDER BY 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got covid
SELECT Location, date, total_cases, Population, (total_cases/Population)*100 as PercentPopulationInfected
FROM Project..CovidDeaths
WHERE location like '%Canada%'
and continent is not null
ORDER BY 1,2

-- Looking at Countries with highest Infections Rate compared to Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount , (MAX(total_cases)/population)*100 as PercentPopulationInfected
FROM Project..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc 

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotaLDeathCount 
FROM Project..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotaLDeathCount desc 


-- BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) as TotaLDeathCount 
FROM Project..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotaLDeathCount desc 

-- GLOBAL NUMBERS
SELECT date, SUM(cast(new_cases as float)) as total_cases , SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(cast(new_cases as float))*100 as DeathPercentage
FROM Project..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Total Vaccinations

--USE CTE
with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
    , SUM(CONVERT(float, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--    , (RollingPeopleVaccinated/population)*100
FROM Project..CovidDeaths dea
join Project..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
Drop table if exists [PercentPopulationVaccinated]
Create table [PercentPopulationVaccinated]
(
[Continent] nvarchar(50),
[Location] nvarchar(50),
[Date] date,
[population] nchar(10),
[New_vaccinations] numeric,
[RollingPeopleVaccinated] numeric
)
Insert into [PercentPopulationVaccinated]
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
    , SUM(CONVERT(float, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM Project..CovidDeaths dea
join Project..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM [PercentPopulationVaccinated]

-- Creating View for store data for later visulization

Create View PercentPopVac as 
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
    , SUM(CONVERT(float, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--    , (RollingPeopleVaccinated/population)*100
FROM Project..CovidDeaths dea
join Project..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null



