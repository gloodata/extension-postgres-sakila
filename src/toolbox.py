from glootil import Toolbox, DynEnum
from state import State
import logging
from datetime import date
from enum import Enum

logger = logging.getLogger("toolbox")
NS = "gd-sakila"
tb = Toolbox(NS, "Sakila", "Sakila Explorer", state=State())


def create_group_chart(title, cols, rows, unit="", chart_type="bar"):
    on_clicks = []
    col_keys = [col[0] for col in cols]
    row_lists = [[row.get(key) for key in col_keys] for row in rows]

    result = {
        "info": {
            "type": "group",
            "chartType": chart_type,
            "title": title,
            "unit": unit,
            "keyName": cols[0][0],
            "valName": cols[1][0],
            "onClick": on_clicks,
        },
        "data": {"cols": cols, "rows": row_lists},
    }
    return result


def create_series_chart(title, cols, rows, chart_type="bar"):
    x, x_title = cols[0]
    serie, serie_title = cols[1]
    y, y_title = cols[2]

    col_keys = [col[0] for col in cols]
    row_lists = [[row.get(key) for key in col_keys] for row in rows]
    on_clicks = []

    return {
        "type": "Series",
        "chartType": chart_type,
        "title": title,
        "unit": "#",
        "xColTitle": x_title,
        "yColTitle": y_title,
        "seriesCol": serie,
        "xCol": x,
        "valCols": [y],
        "pivot": {
            "keyName": serie,
            "valName": y,
        },
        "cols": cols,
        "rows": row_lists,
        "onClick": on_clicks,
    }


def to_area(rows):
    areas = [{"name": row[0], "value": row[1]} for idx, row in enumerate(rows)]
    return areas


def create_area_map(title, cols, rows, map_type="usa"):
    col_keys = [col[0] for col in cols]
    row_lists = [[row.get(key) for key in col_keys] for row in rows]
    areas = to_area(row_lists)
    on_clicks = []
    result = {
        "type": "AreaMap",
        "mapId": map_type,
        "infoId": map_type,
        "onClick": on_clicks,
        "items": areas,
    }
    return result


# ================================
# Declaration of enums and filters
# ================================
@tb.enum(name="category", icon="list")
class FilmCategory(DynEnum):
    """
    Category of films in the Sakila database.
    """

    @staticmethod
    async def search(state: State, query: str = "", limit: int = 100):
        return await state.search("category_enum", query, limit)

    @staticmethod
    async def find_best_match(state: State, query: str = ""):
        return await FilmCategory.search(state, query, limit=1)


@tb.enum(name="store", icon="list")
class Store(DynEnum):
    """
    Store of films in the Sakila database.
    """

    @staticmethod
    async def search(state: State, query: str = "", limit: int = 100):
        return await state.search("store_enum", query, limit)

    @staticmethod
    async def find_best_match(state: State, query: str = ""):
        return await Store.search(state, query, limit=1)


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
    manual_update=False,
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

    Result:
    - A bar chart showing actors with the highest number of film appearances
    """
    rows = await state.run_query(
        "actor_with_most_films",
        start_year=start_year,
        end_year=end_year,
        min_length=min_length,
        max_length=max_length,
        category=category
    )
    return create_group_chart(
        "Actor with most films",
        cols=[["actor_name", "Actor Name"], ["films", "Number of Films"]],
        rows=rows,
        chart_type="bar",
    )


# 2. Monthly rental revenue (Series Bar Chart)
@tb.tool(
    name="Monthly rental revenue",
    examples=[
        "Show monthly rental revenue trends",
        "Revenue by month",
        "Monthly income analysis",
    ],
    manual_update=False,
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

    Result:
    - A line chart showing revenue trends by month
    """
    rows = await state.run_query(
        "monthly_rental_revenue",
        start_date=start_date,
        end_date=end_date,
        store=store,
    )
    return create_series_chart(
        "Monthly Rental Revenue",
        cols=[["p_date", "Month"], ["category_name", "Category"], ["total_revenue", "Revenue ($)"]],
        rows=rows,
        chart_type="bar",
    )


# 3. Film category distribution (Pie Chart)
@tb.tool(
    name="Film category distribution",
    examples=[
        "Show film categories breakdown",
        "Category distribution",
        "Films by genre",
    ],
    manual_update=False,
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

    Result:
    - A pie chart showing the distribution of films by category
    """
    rows = await state.run_query(
        "film_category_distribution",
        start_year=start_year,
        end_year=end_year,
        min_rental_rate=min_rental_rate,
        max_rental_rate=max_rental_rate,
    )
    return create_group_chart(
        "Film Category Distribution",
        cols=[["category_name", "Category"], ["film_count", "Number of Films"]],
        rows=rows,
        chart_type="pie",
    )


# 4. Revenue by country (Area Map)
@tb.tool(
    name="Revenue by country",
    examples=[
        "Show revenue by country",
        "Country revenue analysis",
        "Geographic revenue distribution",
    ],
    manual_update=False,
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

    Result:
    - An area map showing revenue distribution by country
    """
    rows = await state.run_query(
        "revenue_by_country",
        start_date=start_date,
        end_date=end_date,
        store=store,
    )
    return create_area_map(
        "Revenue by Country",
        cols=[["country_name", "Country"], ["total_revenue", "Revenue ($)"]],
        rows=rows,
        map_type="world",
    )


@tb.tool(
    name="Daily rental trends by category",
    examples=[
        "Show daily rental trends",
        "Rental patterns by category",
        "Daily category performance",
    ],
    manual_update=False,
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
    - category_name: Optional category filter (e.g., 'Action', 'Comedy')

    Result:
    - A line chart showing rental trends by category over time
    """
    rows = await state.run_query(
        "daily_rental_trends_by_category",
        start_date=start_date,
        end_date=end_date,
        store=store,
        category=category,
    )
    return create_series_chart(
        "Daily Rental Trends by Category",
        cols=[
            ["rental_date", "Date"],
            ["category_name", "Category"],
            ["rental_count", "Rentals"],
        ],
        rows=rows,
        chart_type="line",
    )


@tb.tool(
    name="Top customers by rentals",
    examples=[
        "Show top customers",
        "Best customers by rental count",
        "Customer rental analysis",
    ],
    manual_update=False,
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

    Result:
    - A bar chart showing top customers by rental count
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
    return create_group_chart(
        "Top Customers by Rentals",
        cols=[
            ["customer_name", "Customer Name"],
            ["rental_count", "Number of Rentals"],
        ],
        rows=rows,
        chart_type="bar",
    )


@tb.tool(
    name="Film length distribution by category",
    examples=[
        "Show film length by category",
        "Average movie duration by genre",
        "Category length analysis",
    ],
    manual_update=False,
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

    Result:
    - A horizontal bar chart showing average film length by category
    """
    rows = await state.run_query(
        "film_length_distribution_by_category",
        start_year=start_year,
        end_year=end_year,
    )
    return create_group_chart(
        "Film Length Distribution by Category",
        cols=[
            ["category_name", "Category"],
            ["avg_length_minutes", "Average Length (minutes)"],
        ],
        rows=rows,
        chart_type="hbar",
    )
