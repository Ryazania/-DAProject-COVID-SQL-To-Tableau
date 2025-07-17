--check data
select * from CovidDeathProject..CovidDeaths$



-- looking into total cases vs Total Deaths in Australia
-- turn out there is over 3% likelihood to die from Covid if 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from CovidDeathProject..CovidDeaths$
where location like '%Australia%'
order by 1,2


--looking at total cases VS population
select location,date,total_cases,population, (total_cases/population)*100 as PercectPopulationInfention
from CovidDeathProject..CovidDeaths$

order by 1,2

-- looking at countries with Highest infection ratec compared to population
select location,population, MAX(total_cases) as highestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfented
from CovidDeathProject..CovidDeaths$
group by population,location
order by  PercentPopulationInfented desc


-- Showing Countries with Highest Death Count per population
-- total deaths needs to be in int
-- without continent is not null it will show World, Asia and other continents instead of countries
select location,MAX(Cast(total_deaths as int)) as HighestTotalDeathCount 
from CovidDeathProject..CovidDeaths$
where continent is not null
group by location
order by  HighestTotalDeathCount desc


--Lets break things down by continent
-- where continent is nul will show north america counting canada and united states
select location,MAX(Cast(total_deaths as int)) as HighestTotalDeathCount 
from CovidDeathProject..CovidDeaths$
where continent is null
group by location
order by  HighestTotalDeathCount desc

-- GLOBAL NUMBERS
-- global death is 3 million people lost their life or about 2% from total infection
select  SUM(new_cases)as total_Cases, SUM(cast(new_deaths as int)) as global_death, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 DeathPercentageGlobally
from CovidDeathProject..CovidDeaths$
where continent is not null
order by 1,2 

-- Now we want to look into the Vaccination

--looking at total population vs vaccinations in canada
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 

from CovidDeathProject..CovidDeaths$ dea
Join CovidDeathProject..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%Canada%'
order by 2,3


--looking at total population vs vaccinations as percentage
-- need to use temp table as cant use column name that we just create CTE
-- if its not the samme collumn in CTE its going to give error
with PopVSVac (continent, location,date, population ,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from CovidDeathProject..CovidDeaths$ dea
Join CovidDeathProject..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%Canada%'
)
select * , (RollingPeopleVaccinated/population)*100
from PopVSVac


--TEMP TABLE
-- creating temp table for the same result above

DROP table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #percentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from CovidDeathProject..CovidDeaths$ dea
Join CovidDeathProject..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 

select * , (RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated 




-- create View to store data for later in Tableau visualization
create view percentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from CovidDeathProject..CovidDeaths$ dea
Join CovidDeathProject..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

--