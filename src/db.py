import logging
import os

import aiosql
import asyncpg

logger = logging.getLogger("db")


class DB:
    def __init__(self):
        self.queries = aiosql.from_path("queries.sql", "asyncpg")

    async def start(self, loop=None):
        logger.info("connecting to database")

        db_host = os.environ.get("POSTGRES_HOST", "localhost")
        db_port = int(os.environ.get("POSTGRES_PORT", 5432))
        db_user = os.environ.get("POSTGRES_USER", "postgres")
        db_password = os.environ.get("POSTGRES_PASSWORD", "sakila")
        db_name = os.environ.get("POSTGRES_DATABASE", "postgres")

        db_min_size = 1
        db_max_size = 5

        self.pool = await asyncpg.create_pool(
            host=db_host,
            port=db_port,
            user=db_user,
            password=db_password,
            database=db_name,
            min_size=db_min_size,
            max_size=db_max_size,
        )

        logger.info("connected to database")

    async def stop(self, pool):
        logger.info("disconnecting from database")

        if pool:
            await pool.close()
            logger.info("disconnected from database")
        else:
            logger.warning("no database connection")

    async def run_query(self, query_name, **args):
        query = getattr(self.queries, query_name)
        async with self.pool.acquire() as conn:
            rows = await query(conn, **args)
            return [dict(row) for row in rows]
