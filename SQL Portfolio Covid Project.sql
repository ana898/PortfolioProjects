Select *
From [SQL Projects]..CovidDeaths
Where continent is not null
	And continent <> ' '
Order by 3 desc

--Select	*
--From [SQL Projects]..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From [SQL Projects]..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at total cases vs total deaths
-- Shows likelihoof of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [SQL Projects]..CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From [SQL Projects]..CovidDeaths
Where location like '%moldova%'
Order by 1,2

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From [SQL Projects]..CovidDeaths
Where location like '%italy%'
Order by 1,2

-- Looking at countries woth highest infection rate compared to Population

Select location, population, max(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentPopulationInfected
From [SQL Projects]..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

-- Showing the countries with highest death count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From [SQL Projects]..CovidDeaths
Where continent is not null
	And continent <> ' '
Group by location
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From [SQL Projects]..CovidDeaths
Where continent is not null
	And continent <> ' '
Group by continent
Order by TotalDeathCount desc



-- GLOBAL NUMBERS grouped by DATE
Select date,SUM(new_cases) as totale_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [SQL Projects]..CovidDeaths
where continent is not null
	And continent <> ' '
Group by date
Order by 1,2	


-- GLOBAL NUMBERS Overall (without grouping by date)
Select SUM(new_cases) as totale_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [SQL Projects]..CovidDeaths
where continent is not null
	And continent <> ' '
Order by 1,2	


--Looking at total population vs total vaccination (with Convert)
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [SQL Projects]..CovidDeaths dea
Join [SQL Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	And dea.continent <> ' '
order by 2,3

--Looking at total population vs total vaccination (with Cast)
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [SQL Projects]..CovidDeaths dea
Join [SQL Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
order by 2,3


-- USE CTE
With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [SQL Projects]..CovidDeaths dea
Join [SQL Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
)
Select*, (RollingPeopleVaccinated/population)*100
From PopVsVac

-- Temp table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations nvarchar(255),
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [SQL Projects]..CovidDeaths dea
Join [SQL Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--	And dea.continent <> ' '
--order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [SQL Projects]..CovidDeaths dea
Join [SQL Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	And dea.continent <> ' '

Select * 
From PercentPopulationVaccinated