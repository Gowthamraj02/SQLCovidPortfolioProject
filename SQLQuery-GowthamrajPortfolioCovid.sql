--Viewing CovidDeaths table data
select * from GowthamrajPortfolio..CovidDeaths
where continent is not null
order by 3,4			--//Order by 3rd and 4th column

--Viewing CovidDeaths table data
select * from GowthamrajPortfolio..CovidVaccinations
where continent is not null
order by 3,4			--//Order by 3rd and 4th column

--Selecting data we're going to use
select location, date,total_cases,new_cases,total_deaths,population 
from GowthamrajPortfolio..CovidDeaths 
where continent is not null
order by 1,2 

--Quick look at total cases vs total deaths
select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as PercentageofDeath
from GowthamrajPortfolio..CovidDeaths
where continent is not null
and location like '%Germany%'
order by 1,2                   --//Percentage of dying due to covid currently in Germany@Deutschland

--Quick look at total cases vs population

select location, date,total_cases,population, (total_cases/population)*100 as PercentageofPopulationInfected
from GowthamrajPortfolio..CovidDeaths
where continent is not null
and location like '%Germany%'
order by 1,2                   --//Percentage of population got covid currently in Germany@Deutschland

--Highly infected countries compared to population
select location, population, max(total_cases) as TotalInfectedCount, max((total_cases/population))*100 as PercentageofPopulationInfected
from GowthamrajPortfolio..CovidDeaths
--where continent is not null and location like '%Germany%'
group by location,population
order by PercentageofPopulationInfected desc

--Higher death count per population of countries
select location, population, max(total_deaths) as TotalDeathCount, max((total_deaths/population))*100 as PercentageofPopulationDied
from GowthamrajPortfolio..CovidDeaths
where continent is not null
--where location like '%Germany%'
group by location,population
order by TotalDeathCount desc

--Higher death count by population of continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount--, max((total_deaths/population))*100 as PercentageofPopulationDied
from GowthamrajPortfolio..CovidDeaths
where continent is not null
--where location like '%Germany%'
group by continent--,population
order by TotalDeathCount desc     --//it's correct format but due to datsaset we're making script change as below

--Higher death count by population of continent
select location, max(cast(total_deaths as int)) as TotalDeathCount--, max((total_deaths/population))*100 as PercentageofPopulationDied
from GowthamrajPortfolio..CovidDeaths
where continent is null
--where location like '%Germany%'
group by location--continent--,population
order by TotalDeathCount desc


--WORLDWIDE NUMBERS
--//Number of total cases on particular date
select date,SUM(new_cases) as NewCases--,total_deaths, (total_deaths/total_cases)*100 as PercentageofDeath
from GowthamrajPortfolio..CovidDeaths
where continent is not null
--where location like '%Germany%'
group by date
order by 1,2                   --//Number of total cases on particular date

--//DeathPercentagebyTotalNewCases
select date,SUM(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as 
DeathrateinPercentage
from GowthamrajPortfolio..CovidDeaths
where continent is not null
--where location like '%Germany%'
group by date
order by 1,2                   


--//Overalldeath percentage till date
select SUM(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as 
DeathrateinPercentage
from GowthamrajPortfolio..CovidDeaths
where continent is not null
--where location like '%Germany%'
--group by date
order by 1,2                


--// Working with both the Covid deaths and Covid Vaccination tables
--select * from GowthamrajPortfolio..CovidVaccinations

select * from GowthamrajPortfolio..CovidDeaths CoD
join GowthamrajPortfolio..CovidVaccinations CoV
	on CoD.location = CoV.location and CoD.date = CoV.date

--Looking at vaccination rate vs population
select cod.continent,cod.location,cod.date, cov.new_vaccinations
from GowthamrajPortfolio..CovidDeaths CoD
join GowthamrajPortfolio..CovidVaccinations CoV
	on CoD.location = CoV.location and CoD.date = CoV.date
where cod.continent is not null
--group by cod.continent
order by 1,2,3,4 

select cod.continent,cod.location,cod.date, cod.population, cov.new_vaccinations, 
cast(cov.total_vaccinations as float),
sum(convert(float, cov.new_vaccinations)) over (partition by cod.location) as NewTotalVaccinations
from GowthamrajPortfolio..CovidDeaths CoD
join GowthamrajPortfolio..CovidVaccinations CoV
	on CoD.location = CoV.location and CoD.date = CoV.date
where cod.continent is not null
--group by cod.continent
order by 2,3    --// here in partition we just get totalvaccination based on each location


select cod.continent,cod.location,cod.date, cod.population, cov.new_vaccinations, 
cast(cov.total_vaccinations as float) as TotalVaccinations,
sum(convert(float, cov.new_vaccinations)) 
over (partition by cod.location order by cod.location,cod.date) as NewTotalVaccinations
from GowthamrajPortfolio..CovidDeaths CoD
join GowthamrajPortfolio..CovidVaccinations CoV
	on CoD.location = CoV.location and CoD.date = CoV.date
where cod.continent is not null
--group by cod.continent
order by 2,3  --// here in partition we get totalvaccination based on each location ordered by loaction, 
					--date.

select cod.continent,cod.location,cod.date, cod.population, cov.new_vaccinations, 
cast(cov.total_vaccinations as float) as TotalVaccinations,
sum(convert(float, cov.new_vaccinations)) 
over (partition by cod.location order by cod.location,cod.date) as NewTotalVaccinations
from GowthamrajPortfolio..CovidDeaths CoD
join GowthamrajPortfolio..CovidVaccinations CoV
	on CoD.location = CoV.location and CoD.date = CoV.date
where cod.continent is not null
--group by cod.continent
order by 2,3

--use CTE

with popvsvacc(continent, location, date, population, new_vaccinations, NewTotalVaccinations)
as
(
select cod.continent,cod.location,cod.date, cod.population, cov.new_vaccinations, 
sum(convert(float, cov.new_vaccinations)) 
over (partition by cod.location order by cod.location,cod.date) as NewTotalVaccinations
--,(NewTotalVaccination/population)*100
from GowthamrajPortfolio..CovidDeaths CoD
join GowthamrajPortfolio..CovidVaccinations CoV
	on CoD.location = CoV.location and CoD.date = CoV.date
where cod.continent is not null
--group by cod.continent
--order by 2,3
)

select *,(NewTotalVaccinations/population)*100 as NewVaccinationsRate from popvsvacc

--temp table
drop table if exists #VaccinationPercentage
create table #VaccinationPercentage
(
continent nvarchar(255), location nvarchar(255), date datetime, population numeric, 
new_vaccinations nvarchar(255), NewTotalVaccinations numeric)

insert into #VaccinationPercentage
select cod.continent,cod.location,cod.date, cod.population, cov.new_vaccinations, 
sum(convert(float, cov.new_vaccinations)) 
over (partition by cod.location order by cod.location,cod.date) as NewTotalVaccinations
--,(NewTotalVaccination/population)*100
from GowthamrajPortfolio..CovidDeaths CoD
join GowthamrajPortfolio..CovidVaccinations CoV
	on CoD.location = CoV.location and CoD.date = CoV.date
where cod.continent is not null
--group by cod.continent
--order by 2,3

select *,(NewTotalVaccinations/population)*100 as NewVaccinationsRate from #VaccinationPercentage


--Creating data VIEW to store data for visulization 

create view VaccinationPercentage as
select cod.continent,cod.location,cod.date, cod.population, cov.new_vaccinations, 
sum(convert(float, cov.new_vaccinations)) 
over (partition by cod.location order by cod.location,cod.date) as NewTotalVaccinations
--,(NewTotalVaccination/population)*100
from GowthamrajPortfolio..CovidDeaths CoD
join GowthamrajPortfolio..CovidVaccinations CoV
	on CoD.location = CoV.location and CoD.date = CoV.date
where cod.continent is not null
--group by cod.continent
--order by 2,3

select * from VaccinationPercentage


select continent, max(cast(total_deaths as int)) as TotalDeathCount--, max((total_deaths/population))*100 as PercentageofPopulationDied
from GowthamrajPortfolio..CovidDeaths
where continent is not null
--where location like '%Germany%'
group by continent--,population
order by TotalDeathCount desc 