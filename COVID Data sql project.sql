SELECT * FROM [Covid project portfolio]..['CovidDeaths'] 
where continent is not null
order by 3,4



--SELECT * FROM [Covid project portfolio]..['CovidVaccinations']
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Covid project portfolio]..['CovidDeaths']
where continent is not null
order by 1,2



--Total Cases vs Total Deaths
-- Likelihood of dying if you get covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Covid project portfolio]..['CovidDeaths']
where location like '%states%' and continent is not null
order by 1,2



--Total cases vs Population
-- oercentage of population that got infected

SELECT Location, date, total_cases, population, (total_cases/population)*100 as percentWithCovid
FROM [Covid project portfolio]..['CovidDeaths']
where continent is not null
--Where location like '%states%'
order by 1,2



-- Countries with highest infection rate compared to pop

SELECT Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as percentPopulationInfected
FROM [Covid project portfolio]..['CovidDeaths']
where continent is not null
--Where location like '%states%'
Group By Location, Population
order by percentPopulationInfected desc



--Countries with Highest deaths per pop

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM [Covid project portfolio]..['CovidDeaths']
where continent is not null
--Where location like '%states%'
Group By Location
order by TotalDeathCount desc



-- By continent

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM [Covid project portfolio]..['CovidDeaths']
where continent is not null
--Where location like '%states%'
Group By continent
order by TotalDeathCount desc



--Global Numbers


SELECT date, SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Covid project portfolio]..['CovidDeaths']
--where location like '%states%' 
where continent is not null
Group By date
order by 1,2

SELECT SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Covid project portfolio]..['CovidDeaths']
--where location like '%states%' 
where continent is not null
--Group By date
order by 1,2



--lets lock at covid vaccination table

SELECT *
From [Covid project portfolio]..['CovidDeaths'] death
Join [Covid project portfolio]..['CovidVaccinations'] vacc
On death.location = vacc.location
and death.date = vacc.date



-- Total Population vs Vaccination

SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(convert(int,vacc.new_vaccinations )) OVER (Partition by death.location Order by death.date) as PeopleVaccinatedRolling
From [Covid project portfolio]..['CovidDeaths'] death
Join [Covid project portfolio]..['CovidVaccinations'] vacc
On death.location = vacc.location
and death.date = vacc.date
where death.continent is not null
order by 2, 3



--Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinatedRolling)
as 
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(convert(int,vacc.new_vaccinations )) OVER (Partition by death.location Order by death.date) as PeopleVaccinatedRolling
From [Covid project portfolio]..['CovidDeaths'] death
Join [Covid project portfolio]..['CovidVaccinations'] vacc
On death.location = vacc.location
and death.date = vacc.date
where death.continent is not null
--order by 2, 3
)
SELECT *, (PeopleVaccinatedRolling/Population)*100 as PercentVaccinated
From PopvsVac



-- Using a temp table

DROP Table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinatedRolling numeric
)
Insert into #percentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(convert(int,vacc.new_vaccinations )) OVER (Partition by death.location Order by death.date) as PeopleVaccinatedRolling
From [Covid project portfolio]..['CovidDeaths'] death
Join [Covid project portfolio]..['CovidVaccinations'] vacc
On death.location = vacc.location
and death.date = vacc.date
--where death.continent is not null
--order by 2, 3

SELECT *, (PeopleVaccinatedRolling/Population)*100 as PercentVaccinated
From #percentPopulationVaccinated


--Views for later use
Create View percentPopulationVaccinated as
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(convert(int,vacc.new_vaccinations )) OVER (Partition by death.location Order by death.date) as PeopleVaccinatedRolling
From [Covid project portfolio]..['CovidDeaths'] death
Join [Covid project portfolio]..['CovidVaccinations'] vacc
On death.location = vacc.location
and death.date = vacc.date
where death.continent is not null

Select *
FROM percentPopulationVaccinated