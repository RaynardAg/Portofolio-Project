Select * 
From PortofolioProject..CovidDeaths
Where continent is not NULL
Order By 3,4

Select * 
From PortofolioProject..CovidVaccinations
Order By 3,4


-- Select the data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
Where continent is not NULL
Order By 1,2


--Looking at the Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract COVID-19 in Indonesia

Select location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where Location='Indonesia'
and continent is not NULL
Order By 1,2


--Looking at Total Cases vs Population
--Shows what percentage of the population has been infected by COVID-19

Select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From PortofolioProject..CovidDeaths
Where Location='Indonesia'
Order By 1,2


--Looking at Countries with Highest Infection Rates compared to Population

Select location, population, MAX(total_cases) as CurrentInfectedCount, Max((total_cases/population))*100 as InfectedPercentage
From PortofolioProject..CovidDeaths
Group By Location, population
Order By InfectedPercentage DESC

--Showing Countries with Highest Death Count

Select location, population, MAX(cast(total_deaths as int)) as CurrentDeaths
From PortofolioProject..CovidDeaths
Where continent is not NULL
Group By Location,population
Order By CurrentDeaths DESC


--Showing Continents with Highest Death Count

Select continent, MAX(cast(total_deaths as int)) as CurrentDeaths
From PortofolioProject..CovidDeaths
Where continent is not NULL
Group By continent
Order By CurrentDeaths DESC


--GLOBAL NUMBERS

--Looking at the percentage of Total Death compared to Total Cases globally daily

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where Continent is not NULL
Group By date
Order By 1,2

--Looking at the percentage of Total Death compared to Total Cases globally 

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where Continent is not NULL
Order By 1,2

--Looking at the rolling count of Vaccinated People by Date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.date) as VaccinatedRollingCount
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
Order By 2,3

--Using CTE to see the progress of Vaccinations in percentage in respect to the Population

With PopVacPercentage (Continent, Location, Date, Population, NewVaccinations, VaccinatedRollingCount)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.date) as VaccinatedRollingCount
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
)
Select *,(VaccinatedRollingCount/Population)*100 as PopVacPercentage
From PopVacPercentage


--Using Temp Table to replicate the same table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	NewVaccinations numeric,
	VaccinatedRollingCount numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.date) as VaccinatedRollingCount
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL

Select *,(VaccinatedRollingCount/Population)*100 as PopVacPercentage
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.date) as VaccinatedRollingCount
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
