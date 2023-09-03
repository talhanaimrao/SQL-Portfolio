SELECT *
FROM [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--order by 3,4
--===================================================================================
-- Select data that we are going to use
--===================================================================================


SELECT Location, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
order by 1,2

--===================================================================================
-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in the respective country
--===================================================================================


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Mortality_Ratio
FROM [Portfolio Project]..CovidDeaths
order by 1,2


--===================================================================================
-- Looking at Total Cases vs Total Deaths for Pakistan over time
-- Shows the likelihood of dying if you contract covid in Pakistan over time
--===================================================================================


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Mortality_Ratio
FROM [Portfolio Project]..CovidDeaths
where location = 'Pakistan'
order by 1,2


--===================================================================================
-- Looking at Total Cases vs Population over time
-- Shows the %age of population that conracted covid over time
--===================================================================================



SELECT Location, date, population, total_cases, (total_cases/population)*100 as Contraction_Rate
FROM [Portfolio Project]..CovidDeaths
where location = 'Pakistan'
order by 1,2 


--===================================================================================
-- Looking at country's highest contraction rate
-- Shows the total %age of population that conracted covid 
--===================================================================================


SELECT Location, population, MAX(total_cases)as Highest_Contraction_Count, Max(total_cases/population)*100 as Highest_Contraction_Rate
FROM [Portfolio Project]..CovidDeaths
--where location = 'Pakistan'
Group by location, population
Order by Highest_Contraction_Rate desc

--===================================================================================
-- Showing the country's highest death count per population
-- Shows the total %age of population that died from COVID
--===================================================================================


SELECT Location, population, MAX(total_deaths)as Highest_Contraction_Count, Max(total_deaths/population)*100 as Highest_Death_Rate
FROM [Portfolio Project]..CovidDeaths
--where location = 'Pakistan'
Group by location, population
Order by Highest_Death_Rate desc


--===================================================================================
-- Showing the country's total death count
--===================================================================================


SELECT Location, MAX(cast(total_deaths as int))as Total_Death_Count
FROM [Portfolio Project]..CovidDeaths
where continent is not null
Group by location
Order by Total_Death_Count desc


--===================================================================================
-- LETS BREAK THINGS DOWN BY CONTINENT
-- showing continents with highest death count per population
--===================================================================================

SELECT continent, MAX(cast(total_deaths as int))as Total_Death_Count
FROM [Portfolio Project]..CovidDeaths
where continent is not null
Group by continent
Order by Total_Death_Count desc


--===================================================================================
-- GLOBAL NUMBERS
--===================================================================================



SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
where continent is not null
--GROUP BY CONTINENT
order by 1,2

SELECT date, SUM(new_cases) as GLOBAL_NEW_CASES, SUM(cast(new_deaths as int)) as GLOBAL_NEW_DEATH
--(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
where continent is not null
GROUP BY date
order by 1,2

--===================================================================================
-- GLOBAL DEATH PERCENTAGE by date
--===================================================================================


SELECT date, SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths
,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GLOBAL_DEATH_PERCETNAGE
FROM [Portfolio Project]..CovidDeaths
where continent is not null
GROUP BY date
order by 1,2


--===================================================================================
-- GLOBAL DEATH PERCENTAGE 
--===================================================================================


SELECT  SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths
,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GLOBAL_DEATH_PERCETNAGE
FROM [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2


--===================================================================================
-- calling all the columns inside the vaccination table
--===================================================================================

SELECT *
FROM [Portfolio Project]..CovidVaccinations


--===================================================================================
-- Joining both tables
--===================================================================================

SELECT *
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidDeaths vac
 on dea.location = vac.location
 and dea.date = vac.date


 --===================================================================================
 -- Looking at total amount of people vaccinated in the world
 --===================================================================================


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
		 on dea.location = vac.location
		 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--===================================================================================
-- showing RUNNING SUM OF VACCINATED PEOPLE ACROSS A COUNTRY OVER TIME
--===================================================================================


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
			,SUM(CONVERT(int, vac.new_vaccinations)) 
			OVER (PARTITION by dea.location order by dea.location, dea.date)
			as RollingPeopleVaccination

FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
		 on dea.location = vac.location
		 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--===========================================================================================
-- USE OF CTE 
--===========================================================================================


WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccination)

as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
			,SUM(CONVERT(int, vac.new_vaccinations)) 
			OVER (PARTITION by dea.location order by dea.location, dea.date)
			as RollingPeopleVaccination

FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
		 on dea.location = vac.location
		 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT * , (RollingPeopleVaccination/population)*100 as RollingVaccinationPercentage
FROM PopVsVac


--===========================================================================================
-- USE OF TEMP TABLE 
--===========================================================================================


-- drop statement allows me to change temp table and it is very handy to add this statement
--before every temp table otherwise we cant modify temp table

DROP TABLE if exists #PercentPopulationVaccinated  
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
			,SUM(CONVERT(int, vac.new_vaccinations)) 
			OVER (PARTITION by dea.location order by dea.location, dea.date)
			as RollingPeopleVaccinated

FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
		 on dea.location = vac.location
		 and dea.date = vac.date
where dea.continent is not null

SELECT * , (RollingPeopleVaccinated/population)*100 as RollingVaccinationPercentage
FROM #PercentPopulationVaccinated


--===========================================================================================
-- USE OF VIEW
--===========================================================================================

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
			,SUM(CONVERT(int, vac.new_vaccinations)) 
			OVER (PARTITION by dea.location order by dea.location, dea.date)
			as RollingPeopleVaccinated

FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
		 on dea.location = vac.location
		 and dea.date = vac.date
where dea.continent is not null


SELECT *
FROM PercentPopulationVaccinated