
Data Source:
The dataset is sourced from Our World in Data, containing global COVID-19 statistics such as cases, deaths, vaccinations, and testing figures across countries and dates.

Objective:
To explore and analyze key COVID-19 metrics using SQL queries to identify trends, compare countries, and prepare summarized data for visualization in Tableau.

Exploratory Steps Using SQL:

Filtering by Country and Date:
Select specific countries or regions and restrict the time frame to relevant periods (e.g., first wave, vaccination rollout phase).

Aggregating Metrics:
Use SUM(), AVG(), and MAX() functions to calculate total cases, average daily deaths, or peak vaccination rates.

Calculating Rates and Ratios:
Compute per capita measures like cases per million or vaccination percentage of the population to enable fair comparisons between countries.

Handling Missing or Inconsistent Data:
Apply WHERE clauses or COALESCE() to manage null values and ensure data integrity.

Ranking and Sorting:
Use ORDER BY and window functions like ROW_NUMBER() to rank countries by case numbers or vaccination coverage.

Joining Tables :
Combine data from different sources, between deaths info and vaccinations, to enrich analysis.
