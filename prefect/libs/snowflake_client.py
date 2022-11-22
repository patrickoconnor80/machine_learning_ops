from sqlalchemy import create_engine
from snowflake.sqlalchemy import URL
import logging
import pandas as pd
import re


class SnowflakeClient:

    def __init__(self, **snowflake_config):
        self.engine = create_engine(URL(**snowflake_config))

    def write_to_snowflake(self, df, table_name, page=1, incremental=False, primary_key='id'):

        # If DataFrame empty, break out of function
        if df.empty is True:
            logging.info(f'{table_name} will not be udpated since DataFrame is empty')
            return

        # Make table name Snowflake compliant
        table_name = self.clean_table_name(table_name)

        # Replace table only if page 1 of api request and load is incremental
        if page == 1 and incremental is False:
            if_exists = 'replace'
        else:
            if_exists = 'append'

            # Retreive primary keys from DataFrame and
            primary_key_list = df['id'].tolist()

            # Create DDL to delete any potnetial duplicates
            primary_key_sql_filter = ", ".join(f"'{primary_key}'" for primary_key in primary_key_list)
            sql_query = f'''
                delete from {table_name}
                where {primary_key} in ({primary_key_sql_filter})
            '''

            # Delete any records that will be inserted
            self.execute_sql_query(sql_query)

        # Connect to Snowflake
        connection = self.engine.connect()

        try:
            # Write table to Snowflake
            df.to_sql(
                name=table_name,
                con=self.engine,
                index=False,
                if_exists=if_exists,
                method='multi',
                chunksize=10000)
        except Exception as e:
            connection.execute('rollback')
            raise e
        finally:
            # Disconnect from Snowflake
            connection.close()

    # Execute SQL Queries in Snowflake
    def execute_sql_query(self, sql_array):

        # Connect to Snowflake
        connection = self.engine.connect()
        counter = 0

        # Allow execution of one SQL query as a string
        if isinstance(sql_array, str):
            sql_array = [sql_array]

        # Execute each query in the array
        for sql_query in sql_array:
            # Execute SQL query
            try:
                connection.execute(sql_query)
                counter += 1
            except Exception as e:
                connection.execute('rollback')
                raise e
            finally:
                # Disconnect from Snowflake
                connection.close()

    # Returns sql query as Pandas Dataframe
    def return_snowflake_dataframe(self, sql_query):

        # Connect to Snowflake
        connection = self.engine.connect()

        try:
            # Execute SQL query
            results = connection.execute(sql_query)
            # Create dataframe from sql query results
            df = pd.DataFrame(results.fetchall())
        except Exception as e:
            connection.execute('rollback')
            raise e
        finally:
            # Disconnect from Snowflake
            connection.close()
        return df

    def return_max_loaded_at(self, table_name):
        if key is None:
            sql_query = f'select max(loaded_at) as max_loaded_at from {table_name}'
        else:
            sql_query = f'''
                select max(loaded_at) as max_loaded_at from {table_name} where key = '{key}'
                '''
        df = self.return_snowflake_dataframe(sql_query)
        loaded_at = df.iloc[0, 0]
        return loaded_at

    def set_max_loaded_at(self, timestamp, table_name='_metadata', key=None):
        if key is None:
            sql_query = f'update {table_name} set loaded_at = {timestamp}'
        else:
            sql_query = f'''
                update {table_name} set loaded_at = {timestamp} where key = '{key}'
            '''
        self.execute_sql_query(sql_query)

    def clean_table_name(self, name):
        name = re.sub(r'[A-Z]', lambda x: '_' + x.group(0).lower(), name)
        return name[1:] if name[0:1] == '_' else name
