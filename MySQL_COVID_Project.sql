SELECT *
FROM portfolioproject.coviddeaths
WHERE continent != ""
ORDER BY 3,4;

SELECT *
FROM portfolioproject.covidvaccinations
ORDER BY 3,4;

UPDATE coviddeaths
SET total_deaths = NULL WHERE total_deaths = '';
    
-- Select data that we are going to be using 
SELECT location, `date`, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent != ""
ORDER BY 1, DAY(`date`);

-- Loking at Total Cases vs Total Deaths
SELECT location, `date`, total_cases, total_deaths, ROUND(((total_deaths/total_cases) * 100), 2) AS deaths_case_percentage
FROM coviddeaths
WHERE location = "Turkey"
ORDER BY 1, DAY(`date`);

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid daily
SELECT location, `date`,total_cases, population, ROUND(((total_cases/population) * 100), 2) AS case_population_percentage
FROM coviddeaths
WHERE location = "Turkey"
ORDER BY 1, DAY(`date`);

-- Looking at Countries with Highest Infection Rates compared to Population?
SELECT location, MAX(total_cases), population, MAX(ROUND(((total_cases/population) * 100), 2)) AS percentage_population_infected
FROM coviddeaths
WHERE continent != ""
GROUP BY location, population
ORDER BY 4 DESC;

-- Showing the Countries with the Highest Death Count per Population
SELECT location, MAX(cast(total_deaths AS SIGNED))
FROM coviddeaths
WHERE continent != ""
GROUP BY location
ORDER BY 2 DESC;

-- Showing the Continents with the Highest Death Count
SELECT location, MAX(cast(total_deaths AS SIGNED))
FROM coviddeaths
WHERE continent = ""
GROUP BY location
ORDER BY 2 DESC;

-- GLOBAL NUMBERS

-- Number of deaths per infection, by day.
SELECT `date`, 
SUM(cast(new_cases  AS SIGNED)) AS total_cases, 
SUM(cast(new_deaths AS SIGNED)) AS total_deaths, 
SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM coviddeaths
WHERE continent != ""
GROUP BY `date`
ORDER BY DAY(`date`);

-- Total number of deaths per infection
SELECT 
SUM(cast(new_cases  AS SIGNED)) AS total_cases, 
SUM(cast(new_deaths AS SIGNED)) AS total_deaths, 
SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM coviddeaths
WHERE continent != "";

-- --------------------------------------------------

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Roling_People_Vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
 	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ""
ORDER BY 2,3;

WITH Vaccinated_Population_Ratio (Cnntinent, Location, Date, Population, New_Vaccinations, Roling_People_Vaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Roling_People_Vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
 	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ""
ORDER BY 2,3
)

SELECT location, SUM(new_vaccinations), ROUND(MAX(Roling_People_Vaccinated/population * 100), 2) AS Vaccinated_Population_Pct
FROM Vaccinated_Population_Ratio
GROUP BY location
ORDER BY 3 DESC
;