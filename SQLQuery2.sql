Select * 
From PortfolioProject..Covid$
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Covid$
Order by 1,2

--Looking at total case v/s total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..Covid$
Order by 1,2
--Total case percentage for country Canada
Select Location, date, population, total_cases, (total_cases/population)*100 as CasePercentageCAN
From PortfolioProject..Covid$
Where location='Canada'
Order by 1,2

--Looking at countries with highest infection rate as compared to population
Select Location, population, MAX(total_cases) as HighestInfectedCountry, MAX((total_cases/population))*100 as PercentagePopulatedInfected
From PortfolioProject..Covid$
Group By Location, population
Order by PercentagePopulatedInfected desc


--Showimg Countries with highest Death Count
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid$
Where continent is not null
Group By Location
Order by TotalDeathCount desc

-- By Continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCountContinent
From PortfolioProject..Covid$
Where continent is not null
Group By continent
Order by TotalDeathCountContinent desc

--By location, continent is null-gives more accurate numbers
Select location, MAX(cast(total_deaths as int)) as TotalDeathCountLoc
From PortfolioProject..Covid$
Where continent is null
Group By location
Order by TotalDeathCountLoc desc

--Showing continents with highest death count rate per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCountCon
From PortfolioProject..Covid$
Where continent is not null
Group By continent
Order by TotalDeathCountCon desc

--GLOBAL NUMBERS death percentage across the world

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..Covid$
where continent is not null
Order by 1,2

--Join tables
Select *
From PortfolioProject..Covid$ C
Join PortfolioProject..CovidVaccinations$ CV
	ON C.location=CV.location
	and CV.date=C.date

--Looking at total population v/s Vaccinations
Select C.location, C.continent, C.date, C.population, CV.new_vaccinations
From PortfolioProject..Covid$ C
Join PortfolioProject..CovidVaccinations$ CV
	ON C.location=CV.location
	and CV.date=C.date
Where C.continent is not null
Order By 1,2,3


With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select C.location, C.continent, C.date, C.population, CV.new_vaccinations
, SUM(CAST(CV.new_vaccinations as bigint)) OVER (Partition by C.Location Order By C.location, C.date) as RollingPeopleVaccinated
From PortfolioProject..Covid$ C
Join PortfolioProject..CovidVaccinations$ CV
	ON C.location=CV.location
	and CV.date=C.date
Where C.continent is not null and new_vaccinations is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select C.location, C.continent, C.date, C.population, CV.new_vaccinations
, SUM(CAST(CV.new_vaccinations as bigint)) OVER (Partition by C.Location Order By C.location, C.date) as RollingPeopleVaccinated
From PortfolioProject..Covid$ C
Join PortfolioProject..CovidVaccinations$ CV
	ON C.location=CV.location
	and CV.date=C.date
Where C.continent is not null and new_vaccinations is not null
--Order By 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Create view to store data for later visualizations

CREATE VIEW PercentPopulatedVaccinated2 as 
Select C.location, C.continent, C.date, C.population, CV.new_vaccinations
, SUM(CAST(CV.new_vaccinations as bigint)) OVER (Partition by C.Location Order By C.location, C.date) as RollingPeopleVaccinated
From PortfolioProject..Covid$ C
Join PortfolioProject..CovidVaccinations$ CV
	ON C.location=CV.location
	and CV.date=C.date
Where C.continent is not null and new_vaccinations is not null
--Order By 2,3

Select * 
From PercentPopulatedVaccinated1