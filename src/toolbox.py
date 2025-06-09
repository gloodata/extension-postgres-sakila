import logging
from datetime import date
from enum import Enum

from glootil import DynEnum, Toolbox

from state import State

logger = logging.getLogger("toolbox")
NS = "gd-sakila"
tb = Toolbox(NS, "Sakila", "Sakila Explorer", state=State())


# ================================
# Declaration of enums and filters
# ================================
@tb.enum(icon="list")
class FilmCategory(DynEnum):
    """
    Category of films in the Sakila database.
    """

    @staticmethod
    async def search(state: State, query: str = "", limit: int = 100):
        return await state.search("category_enum", query, limit)


@tb.enum(icon="list")
class Store(DynEnum):
    """
    Store of films in the Sakila database.
    """

    @staticmethod
    async def search(state: State, query: str = "", limit: int = 100):
        return await state.search("store_enum", query, limit)


@tb.enum(icon="unit")
class YesNo(Enum):
    """
    Yes or No options for filters.
    """

    YES = "Yes"
    NO = "No"


# ====================
# Declaration of tools
# ====================
# 1. Actor with most films (Bar Chart)
@tb.tool(
    name="Actor with most films",
    examples=[
        "Show me actors with most films",
        "Top actors by film count",
        "Which actors appeared in most movies",
    ],
    args={
        "start_year": "from year",
        "end_year": "to year",
        "min_length": "min film length",
        "max_length": "max film length",
    },
)
async def actor_with_most_films(
    state: State,
    start_year: int,
    end_year: int,
    min_length: int,
    max_length: int,
    category: FilmCategory = None,
):
    """
    Finds actors who have appeared in the most films within specified criteria.

    Parameters:
    - start_year: Starting release year for films (default: 2000)
    - end_year: Ending release year for films (default: 2010)
    - min_length: Minimum film length in minutes (default: 60)
    - max_length: Maximum film length in minutes (default: 200)
    - category: Optional film category filter (e.g., 'Action', 'Comedy')

    Returns a bar chart showing actors with the highest number of film appearances.
    """
    rows = await state.run_query(
        "actor_with_most_films",
        start_year=start_year,
        end_year=end_year,
        min_length=min_length,
        max_length=max_length,
        category=category,
    )

    return {
        "info": {
            "type": "group",
            "chartType": "bar",
            "title": "Actor with most films",
            "unit": "",
            "keyName": "actor_name",
            "valName": "films",
        },
        "data": {
            "cols": [["actor_name", "Actor Name"], ["films", "Number of Films"]],
            "rows": [[row.get("actor_name"), row.get("films")] for row in rows],
        },
    }


# 2. Monthly rental revenue (Series Bar Chart)
@tb.tool(
    name="Monthly rental revenue",
    examples=[
        "Show monthly rental revenue trends",
        "Rental revenue by month",
        "Monthly rental income analysis",
    ],
    args={"start_date": "from", "end_date": "to"},
)
async def monthly_rental_revenue(
    state: State,
    start_date: date,
    end_date: date,
    store: Store,
):
    """
    Shows monthly rental revenue trends over time.

    Parameters:
    - start_date: Start date for analysis (default: 1 year ago)
    - end_date: End date for analysis (default: today)
    - store: Optional store filter. Default is all stores (None).

    Returns a line chart showing revenue trends by month.
    """
    rows = await state.run_query(
        "monthly_rental_revenue",
        start_date=start_date,
        end_date=end_date,
        store=store,
    )

    return {
        "type": "Series",
        "chartType": "bar",
        "title": "Monthly Rental Revenue",
        "unit": "#",
        "xColTitle": "Month",
        "yColTitle": "Revenue ($)",
        "seriesCol": "category_name",
        "xCol": "p_date",
        "valCols": ["total_revenue"],
        "pivot": {
            "keyName": "category_name",
            "valName": "total_revenue",
        },
        "cols": [
            ["p_date", "Month"],
            ["category_name", "Category"],
            ["total_revenue", "Revenue ($)"],
        ],
        "rows": [
            [row.get("p_date"), row.get("category_name"), row.get("total_revenue")]
            for row in rows
        ],
    }


# 3. Film category distribution (Pie Chart)
@tb.tool(
    name="Film category distribution",
    examples=[
        "Show film categories breakdown",
        "Category distribution",
        "Films by genre",
    ],
    args={
        "start_year": "from year",
        "end_year": "to year",
        "min_rental_rate": "min rental rate",
        "max_rental_rate": "max rental rate",
    },
)
async def film_category_distribution(
    state: State,
    start_year: int,
    end_year: int,
    min_rental_rate: int,
    max_rental_rate: int,
):
    """
    Shows the distribution of films across different categories.

    Parameters:
    - start_year: Starting release year (default: 2000)
    - end_year: Ending release year (default: 2010)
    - min_rental_rate: Minimum rental rate filter (default: 0.0)
    - max_rental_rate: Maximum rental rate filter (default: 10.0)

    Returns a pie chart showing the distribution of films by category.
    """
    rows = await state.run_query(
        "film_category_distribution",
        start_year=start_year,
        end_year=end_year,
        min_rental_rate=min_rental_rate,
        max_rental_rate=max_rental_rate,
    )

    return {
        "info": {
            "type": "group",
            "chartType": "pie",
            "title": "Film Category Distribution",
            "unit": "",
            "keyName": "category_name",
            "valName": "film_count",
        },
        "data": {
            "cols": [["category_name", "Category"], ["film_count", "Number of Films"]],
            "rows": [[row.get("category_name"), row.get("film_count")] for row in rows],
        },
    }


# 4. Revenue by country (Area Map)
@tb.tool(
    name="Revenue by country",
    examples=[
        "Show revenue by country",
        "Country revenue analysis",
        "Geographic revenue distribution",
    ],
    args={"start_date": "from", "end_date": "to"},
)
async def revenue_by_country(
    state: State,
    start_date: date,
    end_date: date,
    store: Store,
):
    """
    Shows total revenue generated by country.

    Parameters:
    - start_date: Start date for analysis (default: 1 year ago)
    - end_date: End date for analysis (default: today)
    - store: Optional store filter. Default is all stores (None).

    Returns an area map showing revenue distribution by country.
    """
    rows = await state.run_query(
        "revenue_by_country",
        start_date=start_date,
        end_date=end_date,
        store=store,
    )

    areas = [
        {"name": row.get("country_name"), "value": row.get("total_revenue")}
        for row in rows
    ]

    return {
        "type": "AreaMap",
        "mapId": "world",
        "items": areas,
    }


# 5. Daily rental trends by category (Line Chart)
@tb.tool(
    name="Daily rental trends by category",
    examples=[
        "Show daily rental trends",
        "Rental patterns by category",
        "Daily category performance",
    ],
    args={"start_date": "from", "end_date": "to"},
)
async def daily_rental_trends_by_category(
    state: State,
    start_date: date,
    end_date: date,
    store: Store,
    category: FilmCategory = None,
):
    """
    Shows daily rental trends broken down by film category.

    Parameters:
    - start_date: Start date for analysis (default: 30 days ago)
    - end_date: End date for analysis (default: today)
    - store: Optional store filter. Default is all stores (None).
    - category: Optional category filter (e.g., 'Action', 'Comedy')

    Returns a line chart showing rental trends by category over time.
    """
    rows = await state.run_query(
        "daily_rental_trends_by_category",
        start_date=start_date,
        end_date=end_date,
        store=store,
        category=category,
    )

    return {
        "type": "Series",
        "chartType": "line",
        "title": "Daily Rental Trends by Category",
        "unit": "#",
        "xColTitle": "Date",
        "yColTitle": "Rentals",
        "seriesCol": "category_name",
        "xCol": "rental_date",
        "valCols": ["rental_count"],
        "pivot": {
            "keyName": "category_name",
            "valName": "rental_count",
        },
        "cols": [
            ["rental_date", "Date"],
            ["category_name", "Category"],
            ["rental_count", "Rentals"],
        ],
        "rows": [
            [row.get("rental_date"), row.get("category_name"), row.get("rental_count")]
            for row in rows
        ],
    }


# 6. Top customers by rental count (Bar Chart)
@tb.tool(
    name="Top customers by rentals",
    examples=[
        "Show top customers",
        "Best customers by rental count",
        "Customer rental analysis",
    ],
    args={
        "start_date": "from",
        "end_date": "to",
        "min_length": "min film length",
        "max_length": "max film length",
        "active_only": "only active",
    },
)
async def top_customers_by_rentals(
    state: State,
    start_date: date,
    end_date: date,
    store: Store,
    min_length: int,
    max_length: int,
    active_only: YesNo = YesNo.YES,
):
    """
    Shows customers with the highest rental counts.

    Parameters:
    - start_date: Start date for analysis (default: 1 year ago)
    - end_date: End date for analysis (default: today)
    - store: Optional store filter. Default is all stores (None).
    - min_length: Minimum film length filter (default: 60)
    - max_length: Maximum film length filter (default: 200)
    - active_only: Show only active customers (default: Yes)

    Returns a bar chart showing top customers by rental count.
    """
    rows = await state.run_query(
        "top_customers_by_rentals",
        start_date=start_date,
        end_date=end_date,
        store=store,
        min_length=min_length,
        max_length=max_length,
        active_only=active_only,
    )

    return {
        "info": {
            "type": "group",
            "chartType": "bar",
            "title": "Top Customers by Rentals",
            "unit": "",
            "keyName": "customer_name",
            "valName": "rental_count",
        },
        "data": {
            "cols": [
                ["customer_name", "Customer Name"],
                ["rental_count", "Number of Rentals"],
            ],
            "rows": [
                [row.get("customer_name"), row.get("rental_count")] for row in rows
            ],
        },
    }


# 7. Film length distribution by category (Bar Chart)
@tb.tool(
    name="Film length distribution by category",
    examples=[
        "Show film length by category",
        "Average movie duration by genre",
        "Category length analysis",
    ],
    args={"start_year": "from year", "end_year": "to year"},
)
async def film_length_distribution_by_category(
    state: State,
    start_year: int,
    end_year: int,
):
    """
    Shows average film length by category.

    Parameters:
    - start_year: Starting release year (default: 2000)
    - end_year: Ending release year (default: 2010)

    Returns a horizontal bar chart showing average film length by category.
    """
    rows = await state.run_query(
        "film_length_distribution_by_category",
        start_year=start_year,
        end_year=end_year,
    )

    return {
        "info": {
            "type": "group",
            "chartType": "hbar",
            "title": "Film Length Distribution by Category",
            "unit": "",
            "keyName": "category_name",
            "valName": "avg_length_minutes",
        },
        "data": {
            "cols": [
                ["category_name", "Category"],
                ["avg_length_minutes", "Average Length (minutes)"],
            ],
            "rows": [
                [row.get("category_name"), row.get("avg_length_minutes")]
                for row in rows
            ],
        },
    }
