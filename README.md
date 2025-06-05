# Sakila Analytics Extension (Gloodata)

A Python extension for [Gloodata](https://gloodata.com/) that provides comprehensive film rental analytics and dashboards using the classic Sakila sample database (PostgreSQL version). Sakila represents a DVD rental store with data about films, actors, customers, and rental transactions.

![Extension Preview](https://raw.githubusercontent.com/gloodata/extension-postgres-sakila/main/resources/ext-preview.webp)

## Key Features

- 📊 **Analytics Tools**
    - **Actor Performance Analysis**  
        Bar chart showing actors with the most film appearances.
    - **Monthly Rental Revenue Dashboard**  
        Revenue trends analysis over time with category breakdown.
    - **Film Category Distribution**  
        Pie chart showing the distribution of films across genres.
    - **Geographic Revenue Analysis**  
        World map showing revenue distribution by country.
    - **Daily Rental Trends**  
        Line chart tracking daily rental patterns by category.
    - **Customer Analysis Dashboard**  
        Top customers by rental count and activity analysis.
    - **Film Length Analysis**  
        Horizontal bar chart showing average film duration by category.

- 🎯 **Smart Filtering System**  
    Each function supports multiple filters for dynamic analysis:
    - Date ranges for rental period analysis
    - Film release year filters (start_year, end_year)
    - Film length filters (min_length, max_length minutes)
    - Rental rate filters (min/max rental rates)
    - Category filters for genre-specific analysis
    - Store filters for location-based insights
    - Active customer filters for current analysis

- 📈 **Diverse Visualization Types**
    - Bar charts for actor and customer comparisons
    - Line charts for rental trends over time
    - Pie charts for category distributions
    - Horizontal bar charts for film length analysis
    - World maps for geographic revenue distribution
    - Series charts for multi-dimensional temporal data

- 🔍 **Film Industry Intelligence Focus**  
    The queries answer critical business questions like:
    - Which actors appear in the most films?
    - What are our seasonal rental patterns?
    - Which film categories are most popular?
    - Where do our highest revenues come from geographically?
    - Who are our most valuable customers?
    - What's the average film length by genre?
    - How do daily rental patterns vary by category?

## Setup and Installation

### Prerequisites

- Python 3.12 or higher
- [uv](https://docs.astral.sh/uv/)
- [Gloodata](https://gloodata.com/download/)
- PostgreSQL server with Sakila sample database

Check that you are in a recent version of `uv`:

```bash
uv self update
```

### Project Setup

1. **Clone the repository**:
     ```bash
     git clone https://github.com/gloodata/extension-postgres-sakila
     cd extension-postgres-sakila
     ```

2. **Start Sakila PostgreSQL docker database**
    ```bash
    docker run --platform linux/amd64 -e POSTGRES_PASSWORD=sakila -p 5432:5432 -d frantiseks/postgres-sakila
    ```

3. **Optional - Configure PostgreSQL connection**:  
     Set the following environment variables as needed. Not needed if you run the Sakila database as indicated in step #2:
     - `POSTGRES_HOST` (default: `localhost`)
     - `POSTGRES_PORT` (default: `5432`)
     - `POSTGRES_USER` (default: `postgres`)
     - `POSTGRES_PASSWORD` (default: `sakila`)
     - `POSTGRES_DATABASE` (default: `postgres`)

4. **Run the extension**:
     ```bash
     uv run src/main.py --host 127.0.0.1 --port 8886
     ```

## Available Visualizations

### 1. Actor with Most Films

Bar chart showing actors who have appeared in the most films within specified criteria.

Example queries:
- "Show me actors with most films"
- "Top actors by film count"
- "Which actors appeared in most movies"

**Tool**: `actor_with_most_films`

**Parameters**:
- `start_year`: Starting release year for films (default: 2000)
- `end_year`: Ending release year for films (default: 2010)
- `min_length`: Minimum film length in minutes (default: 60)
- `max_length`: Maximum film length in minutes (default: 200)
- `category`: Optional film category filter (e.g., 'Action', 'Comedy')

**Chart**: `bar`

### 2. Monthly Rental Revenue

Series bar chart showing monthly rental revenue trends over time with category breakdown.

Example queries:
- "Show monthly rental revenue trends"
- "Revenue by month"
- "Monthly income analysis"

**Tool**: `monthly_rental_revenue`

**Parameters**:
- `start_date`: Start date for analysis (default: 1 year ago)
- `end_date`: End date for analysis (default: today)
- `store`: Optional store filter. Default is all stores (None)

**Chart**: `bar` (series)

### 3. Film Category Distribution

Pie chart showing the distribution of films across different categories.

Example queries:
- "Show film categories breakdown"
- "Category distribution"
- "Films by genre"

**Tool**: `film_category_distribution`

**Parameters**:
- `start_year`: Starting release year (default: 2000)
- `end_year`: Ending release year (default: 2010)
- `min_rental_rate`: Minimum rental rate filter (default: 0.0)
- `max_rental_rate`: Maximum rental rate filter (default: 10.0)

**Chart**: `pie`

### 4. Revenue by Country

Area map showing total revenue generated by country.

Example queries:
- "Show revenue by country"
- "Country revenue analysis"
- "Geographic revenue distribution"

**Tool**: `revenue_by_country`

**Parameters**:
- `start_date`: Start date for analysis (default: 1 year ago)
- `end_date`: End date for analysis (default: today)
- `store`: Optional store filter. Default is all stores (None)

**Chart**: `world` area map

### 5. Daily Rental Trends by Category

Line chart showing daily rental trends broken down by film category.

Example queries:
- "Show daily rental trends"
- "Rental patterns by category"
- "Daily category performance"

**Tool**: `daily_rental_trends_by_category`

**Parameters**:
- `start_date`: Start date for analysis (default: 30 days ago)
- `end_date`: End date for analysis (default: today)
- `store`: Optional store filter. Default is all stores (None)
- `category`: Optional category filter (e.g., 'Action', 'Comedy')

**Chart**: `line` (series)

### 6. Top Customers by Rentals

Bar chart showing customers with the highest rental counts.

Example queries:
- "Show top customers"
- "Best customers by rental count"
- "Customer rental analysis"

**Tool**: `top_customers_by_rentals`

**Parameters**:
- `start_date`: Start date for analysis (default: 1 year ago)
- `end_date`: End date for analysis (default: today)
- `store`: Optional store filter. Default is all stores (None)
- `min_length`: Minimum film length filter (default: 60)
- `max_length`: Maximum film length filter (default: 200)
- `active_only`: Show only active customers (default: Yes)

**Chart**: `bar`

### 7. Film Length Distribution by Category

Horizontal bar chart showing average film length by category.

Example queries:
- "Show film length by category"
- "Average movie duration by genre"
- "Category length analysis"

**Tool**: `film_length_distribution_by_category`

**Parameters**:
- `start_year`: Starting release year (default: 2000)
- `end_year`: Ending release year (default: 2010)

**Chart**: `hbar` (horizontal bar)

## Development

### Project Structure

Files you may want to check first:

```
extension-postgres-sakila/
├── src/
│   ├── main.py             # Main application entry point
│   ├── toolbox.py          # Main extension logic and tools
│   └── state.py            # State management and database queries
├── queries.sql             # SQL queries for analytics
└── resources/              # Images and static assets
```

### Adding New Visualizations

1. Define new SQL queries in `queries.sql`
2. Create tool functions in `src/toolbox.py` using the `@tb.tool` decorator
3. Specify visualization types and parameters in the return dictionary
4. Use the helper functions (`create_group_chart`, `create_series_chart`, `create_area_map`) for consistent chart formatting

### Docker Management Commands

Start the database:
```bash
docker run --platform linux/amd64 -e POSTGRES_PASSWORD=sakila -p 5432:5432 -d frantiseks/postgres-sakila
```

Stop the database:
```bash
docker stop $(docker ps -a -q --filter "status=running" --filter "ancestor=frantiseks/postgres-sakila")
```

Remove stopped containers:
```bash
docker rm $(docker ps -a -q --filter "status=exited" --filter "ancestor=frantiseks/postgres-sakila")
```

## Technologies

- Python
- PostgreSQL
- [uv](https://docs.astral.sh/uv/)
- Sakila Sample Database

## Data Sources

- Sakila sample database (PostgreSQL version)
- DVD rental store data including films, actors, customers, and rental transactions

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

For questions, issues, or contributions, please open an issue on GitHub or contact the maintainers.