Select *
From PortfolioProject..covidDeaths
Where continent is not null
order by 3,4


Select *
From PortfolioProject..covidVaccination
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covidDeaths
order by 1,2
--Looking at Total Cases Vs Total Deaths
--Shows Likelihood of dying if you contract coivd in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..covidDeaths
Where Location like '%Egypt%'
order by 1,2

--Looking at Total cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases_per_million, Population, (total_cases/Population)*100 as PercentagePopulationInfected
From PortfolioProject..covidDeaths
Where Location like '%Egypt%'
And continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population
Select Location,Population, max(total_cases) as HighestInfectionCount_per_M, MAX((total_cases/Population))*100 as PercentagePopulationInfected
From PortfolioProject..covidDeaths
Where continent is not null
Group by Location, Population
order by PercentagePopulationInfected desc

--	LET'S BREAK THINGS DOWN BY CONTINENT
--Select Location, max(CAST(total_deaths as int)) as TotalDeathsCount
--From PortfolioProject..covidDeaths
--Where continent is null
--Group by Location
--order by TotalDeathsCount desc


-- Showing Countries with Highest Death Count Per Population
Select Location, max(CAST(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..covidDeaths
Where continent is not null
Group by Location
order by TotalDeathsCount desc


-- Showing contintents with the highest death count per population
Select continent, max(CAST(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..covidDeaths
Where continent is not null
Group by continent
order by TotalDeathsCount desc


-- Global Numbers
Select date, SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Death, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as Deathpercentage
From PortfolioProject..covidDeaths
Where continent is not null
Group by date
order by 1,2



-- A cross all worlds
Select  SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Death, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as Deathpercentage
From PortfolioProject..covidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccination
-- So how many people what is the total amount of people in the world that have been
-- vaccinated that is what we are going to do
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(int,V.new_vaccinations )) OVER (PARTITION BY D.location ORDER BY D.location) as RollingPeopleVaccination
From  PortfolioProject..covidDeaths D
	Join PortfolioProject..covidVaccination V
	ON D.location = V.location
	and D.date = V.date 
WHERE D.continent is not null
ORDER BY 2,3 

-- how many people in the country are vaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(int,V.new_vaccinations )) OVER (PARTITION BY D.location ORDER BY D.location) as RollingPeopleVaccination
--,(RollingPeopleVaccination / D.population) *100
From  PortfolioProject..covidDeaths D
	Join PortfolioProject..covidVaccination V
	ON D.location = V.location
	and D.date = V.date 
WHERE D.continent is not null
ORDER BY 2,3 

-- USE CTE	
WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations ,RollingPeopleVaccination )
AS
( 
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(int,V.new_vaccinations )) OVER (PARTITION BY D.location ORDER BY D.location) as RollingPeopleVaccination
--,(RollingPeopleVaccination / D.population) *100
From  PortfolioProject..covidDeaths D
	Join PortfolioProject..covidVaccination V
	ON D.location = V.location
	and D.date = V.date 
WHERE D.continent is not null
)
SELECT *, (RollingPeopleVaccination / population) *100
FROM PopvsVac



-- TEMP Table
DROP TABLE if exists aPercentPopulationVaccinated
CREATE TABLE aPercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccination numeric
)

insert into aPercentPopulationVaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST( V.new_vaccinations AS BIGINT)) OVER (PARTITION BY D.location ORDER BY D.location, D.Date) as RollingPeopleVaccination
--,(RollingPeopleVaccination / D.population) *100
From  PortfolioProject..covidDeaths D
	  Join PortfolioProject..covidVaccination V
	  ON D.location = V.location
	  and D.date = V.date 
WHERE D.continent is not null

SELECT *, (RollingPeopleVaccination / population) *100
FROM aPercentPopulationVaccinated

-- ANATHER TEMP TABLE
DROP TABLE if exists aPercentPopulationVaccinated1
CREATE TABLE aPercentPopulationVaccinated1
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccination numeric
)

insert into aPercentPopulationVaccinated1
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST( V.new_vaccinations AS BIGINT)) OVER (PARTITION BY D.location ORDER BY D.location, D.Date) as RollingPeopleVaccination
--,(RollingPeopleVaccination / D.population) *100
From  PortfolioProject..covidDeaths D
	  Join PortfolioProject..covidVaccination V
	  ON D.location = V.location
	  and D.date = V.date 
--WHERE D.continent is not null

SELECT *, (RollingPeopleVaccination / population) *100
FROM aPercentPopulationVaccinated


-- Creating Veiw to Store data for later visualization
CREATE View PercentPopulationVaccinated as
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST( V.new_vaccinations AS BIGINT)) OVER (PARTITION BY D.location ORDER BY D.location, D.Date) as RollingPeopleVaccination
--,(RollingPeopleVaccination / D.population) *100
From  PortfolioProject..covidDeaths D
	  Join PortfolioProject..covidVaccination V
	  ON D.location = V.location
	  and D.date = V.date 
WHERE D.continent is not null




SELECT *
From  PortfolioProject..covidDeaths D
Join PortfolioProject..covidVaccination V
ON D.location = V.location
and D.date = V.date 