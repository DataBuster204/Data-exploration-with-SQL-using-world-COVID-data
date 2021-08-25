SELECT *
FROM portfolioproject.dbo.coviddeaths
WHERE continent is not NULL
ORDER BY 3, 4


--SELECT *
--FROM portfolioproject.dbo.CovidVaccinations
--ORDER BY 3, 4


--Selecting useful/relevant data

SELECT location, Date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.dbo.coviddeaths
WHERE continent is not NULL
Order by 1, 2


--Looking at total cases vs total deaths
--This data shows the possibility of dying if one contacts COVID in his country
SELECT location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM portfolioproject.dbo.coviddeaths
WHERE Location like '%states%'
and continent is not NULL
Order by 1, 2


--Looking at the Total Cases vs the Population
--Shows what percentage of the population that has got COVID
SELECT location, Date, total_cases, population, (total_cases/population)*100 AS PopulationInfectionPercentage
FROM portfolioproject.dbo.coviddeaths
WHERE continent is not NULL
--WHERE Location like '%states%'
Order by 1, 2


--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PopulationPercentageInfected
FROM portfolioproject.dbo.coviddeaths
--WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY location, population
Order by PopulationPercentageInfected desc


--Showing the country with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM portfolioproject.dbo.coviddeaths
--WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY location
Order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT




--Showing the continent with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM portfolioproject.dbo.coviddeaths
--WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY continent
Order by TotalDeathCount desc



--GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) AS Total_deaths, SUM(CAST(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM portfolioproject.dbo.coviddeaths
--WHERE Location like '%states%'
WHERE continent is not NULL
--GROUP BY date
Order by 1, 2



--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
, 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
Order by 1, 2, 3



--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE


CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)



INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--Order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated



--Creating View to store data for later visualizations 

CREATE VIEW PercentagePopulationVaccinated2 as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--Order by 2, 3
	

SELECT *
FROM #PercentagePopulationVaccinated