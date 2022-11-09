select*
from portfolioproject..coviddeaths
where continent is null
order by 3,4

--select*
--from portfolioproject..covidvaccination
--order by 3,4

select data that we are going to be using


select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..coviddeaths
order by 1,2

--looking at total cases VS total Deaths
--shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..coviddeaths
where location like 'Italy'
order by 1,2

--looking at the total cases vs population

select location, date, population, total_cases, (total_cases/population)*100 as percentpopulationinfected
from portfolioproject..coviddeaths
--where location like '%states%'
order by 1,2

--looking at countries with the highest infection rate compared to population

select location, population, max(total_cases) as HighInfectionCount, max((total_cases/population))*100 as percentpopulationinfected
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by location, population
order by percentpopulationinfected desc


--showing countries with the highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathscount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathscount desc

 --SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT

select continent, max(cast(total_deaths as int)) as totaldeathscount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathscount desc


--GLOBAL DEATH

select  date, sum(new_cases) as total_cases, sum(cast(total_deaths as int)) as total_death, sum(cast(total_deaths as int))/sum(new_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2
 
select sum(new_cases) as total_cases, sum(cast(total_deaths as int)) as total_death, sum(cast(total_deaths as int))/sum(new_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

---------------

--LOOKING AT TOTAL POPULATION VS VACCINATION

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3
 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
 order by dea.location, dea.date) as continuedpeoplevaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3
--USE CTE

with popvsvac (continent, location, date, population, new_vaccinations, continuedpeoplevaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
 order by dea.location, dea.date) as continuedpeoplevaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (continuedpeoplevaccinated/population)*100
from popvsvac


--TEMP TABLE

create table #percentpopulationvaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
Nontinuedpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
 order by dea.location, dea.date) as continuedpeoplevaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (continuedpeoplevaccinated/population)*100
from #percentpopulationvaccinated



--TEMP TABLE
Drop table if exist #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
continuedpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
 order by dea.location, dea.date) as continuedpeoplevaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (continuedpeoplevaccinated/population)*100
from #percentpopulationvaccinated



--creating view to store data for later visualization

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
 order by dea.location, dea.date) as continuedpeoplevaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

create view totalcasesvspopulation as
select location, date, population, total_cases, (total_cases/population)*100 as percentpopulationinfected
from portfolioproject..coviddeaths
--where location like '%states%'
--order by 1,2

create view highestinfectedcountries as
select location, population, max(total_cases) as HighInfectionCount, max((total_cases/population))*100 as percentpopulationinfected
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by location, population
--order by percentpopulationinfected desc

create view countrieswithhighestdeathcountperpopulation as
select location, max(cast(total_deaths as int)) as totaldeathscount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by location
--order by totaldeathscount desc

create view continentwithhighestdeathcount as
select continent, max(cast(total_deaths as int)) as totaldeathscount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
--order by totaldeathscount desc

create view Globaldeath as
select  date, sum(new_cases) as total_cases, sum(cast(total_deaths as int)) as total_death, sum(cast(total_deaths as int))/sum(new_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by date
--order by 1,2

select*
from Globaldeath