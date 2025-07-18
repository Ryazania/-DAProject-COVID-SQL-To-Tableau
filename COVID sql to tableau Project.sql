--test the file
SELECT * FROM CovidDeathProject..CovidDeaths$
SELECT * FROM CovidDeathProject..CovidVaccinations$

--selecting data that we are going to be using
SELECT location,date,total_cases,total_deaths,population
FROM CovidDeathProject..CovidDeaths$

-- Total Cases VS Total Deaths percentage
SELECT location,total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM CovidDeathProject..CovidDeaths$
where location like '%States%' --Lots of deaths
ORDER BY 1,2

-- looking at Total Case VS Population and Percentage contracted Covid
SELECT continent, population, total_cases, (total_cases/population) * 100 as PercentageInfected
FROM CovidDeathProject..CovidDeaths$

-- looking at Countries with highest Infection rate compared to its population
SELECT location, population, MAX(CONVERT(INT,total_cases) )as HighestInfectionRate,  MAX(total_cases/population) *100 as PercentOfPopulation
FROM CovidDeathProject..CovidDeaths$
GROUP BY location, population
ORDER BY PercentOfPopulation DESC

--looking at countries with highest death rate compared to its population
SELECT location, population, MAX(CAST(total_deaths AS INT))as HighestDeath 
FROM CovidDeathProject..CovidDeaths$
WHERE continent is not NULL
GROUP BY location,population
ORDER BY HighestDeath DESC

/* 
lOOKING INTO CONTINENT
*/

--Highest death in continent
SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM CovidDeathProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY continent DESC

--GLOBAL death numbers
SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Death,
SUM(CAST(new_deaths as int))/SUM(new_cases) *100 as Death_Percentage
FROM CovidDeathProject..CovidDeaths$
WHERE continent is not null


--VACCINATION 

--looking at vaccination vs population
SELECT DEA.continent, DEA.location,DEA.date, DEA.population, VAC.new_vaccinations
FROM CovidDeathProject..CovidDeaths$ DEA
JOIN CovidDeathProject..CovidVaccinations$ VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not NULL
ORDER BY 2,3

--rolling count vaccination added up daily
SELECT DEA.continent, DEA.location,DEA.date, DEA.population,
VAC.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) 
OVER (partition by DEA.location ORDER BY DEA.location, DEA.date) as Rolling_Vaccination_Num
FROM CovidDeathProject..CovidDeaths$ DEA
JOIN CovidDeathProject..CovidVaccinations$ VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not NULL
and DEA.location like 'albania' -- easier check the vaccinanation roll and up is working because of its number
ORDER BY 2,3


--Percentage rolling vaccination
SELECT DEA.continent, DEA.location,DEA.date, DEA.population,
VAC.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) 
OVER (partition by DEA.location ORDER BY DEA.location, DEA.date) as Rolling_Vaccination_Num,
FROM CovidDeathProject..CovidDeaths$ DEA
JOIN CovidDeathProject..CovidVaccinations$ VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not NULL
and DEA.location like 'albania' -- easier check the vaccinanation roll and up is working because of its number
ORDER BY 2,3


-- USE CTE for updated percentage rolling vaccination daily

WITH PopVSVac (continent,location, date, population,new_vaccinations, Rolling_Vaccination_Num) 
as 
(
SELECT DEA.continent, DEA.location,DEA.date, DEA.population,
VAC.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) 
OVER (partition by DEA.location ORDER BY DEA.location, DEA.date) as Rolling_Vaccination_Num
FROM CovidDeathProject..CovidDeaths$ DEA
JOIN CovidDeathProject..CovidVaccinations$ VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not NULL
and DEA.location like 'albania' -- easier check the vaccinanation roll and up is working because of its number
--ORDER BY 2,3
)
SELECT * , (Rolling_Vaccination_Num/population) *100 as Updated_Vaccination_rate
FROM PopVSVac 

-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR (255),
location NVARCHAR (255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Vaccination_Num numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location,DEA.date, DEA.population,
VAC.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) 
OVER (partition by DEA.location ORDER BY DEA.location, DEA.date) as Rolling_Vaccination_Num
FROM CovidDeathProject..CovidDeaths$ DEA
JOIN CovidDeathProject..CovidVaccinations$ VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not NULL

SELECT * , (Rolling_Vaccination_Num/population) *100 as Updated_Vaccination_rate
FROM #PercentPopulationVaccinated 

--CREATING VIEW TO STORE DATE FOR LATER VISUALISATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location,DEA.date, DEA.population,
VAC.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) 
OVER (partition by DEA.location ORDER BY DEA.location, DEA.date) as Rolling_Vaccination_Num
FROM CovidDeathProject..CovidDeaths$ DEA
JOIN CovidDeathProject..CovidVaccinations$ VAC
	on DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not NULL

--LOOKING INTO MY NEW VIEW
select *
from PercentPopulationVaccinated


--TABLEAU Table 1 - GLOBAL NUM
SELECT SUM(new_cases) as Total_Covid_cases, SUM(CAST(new_deaths AS INT)) as Total_Deaths,
SUM(CAST(new_deaths as int)) / SUM (new_cases) * 100 as Percentage_Of_Death
FROM CovidDeathProject..CovidDeaths$


-- Tableau Table 2 -- CONTINENT DEATH NUM 
 SELECT location, SUM (CAST(new_deaths AS INT)) as Total_Death_Count
 FROM CovidDeathProject..CovidDeaths$
 WHERE continent IS NULL
 AND location not in ('World', 'European Union', 'International')
 GROUP BY location
 ORDER BY Total_Death_Count DESC

 -- Tableau Table 3 -- NUMBER OF DEATHS IN EACH COUNTRY
 SELECT location, population, MAX(total_cases) as Highest_Infection_Count,
 MAX(total_cases / population) * 100 as Percent_Infected
 FROM CovidDeathProject..CovidDeaths$
 GROUP BY location, population

 -- tableau table 4 -- 
 SELECT location, population, date, MAX(total_cases) as highest_infection_num,
 MAX(total_cases/population) * 100 as Percent_Infected
FROM CovidDeathProject..CovidDeaths$
GROUP BY location, population, date

--tableau table 5
SELECT location, date, population, total_cases, total_deaths
FROM CovidDeathProject..CovidDeaths$

--tableau table 6 -- PopVSVac