Select *
From Portofolio_Project..CovidDeaths$
where continent is not null
order by 3,4

/*Select *
From Portofolio_Project..CovidVaccinations$
order by 3,4*/

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Portofolio_Project..CovidDeaths$
order by 1,2

--Looking at the total cases vs total deaths, the percentage of people who died
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portofolio_Project..CovidDeaths$
Where location like '%Romania%'
and continent is not null
order by 1,2

--total cases vs the population
--Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as CovidInfectionPercentage
From Portofolio_Project..CovidDeaths$
--Where location like '%Romania%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAx((total_cases/population))*100 as CovidInfectionPercentage
From Portofolio_Project..CovidDeaths$
Group by location, population
order by CovidInfectionPercentage desc


-- Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portofolio_Project..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Romania%'
where continent is not null 
--Group By date
order by 1,2

--TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portofolio_Project..CovidDeaths$ dea
join Portofolio_Project..CovidVaccinations$ vac
on dea.location =  vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopVsVAc (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Portofolio_Project..CovidDeaths$ dea
join Portofolio_Project..CovidVaccinations$ vac
on dea.location =  vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac



--TEMP TABLE
-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portofolio_Project..CovidDeaths$ dea
join Portofolio_Project..CovidVaccinations$ vac
on dea.location =  vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portofolio_Project..CovidDeaths$ dea
join Portofolio_Project..CovidVaccinations$ vac
on dea.location =  vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated