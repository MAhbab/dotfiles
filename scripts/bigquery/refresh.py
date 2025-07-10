from google.cloud import bigquery
from concurrent.futures import ThreadPoolExecutor, as_completed
import json
import google.auth
import click
from tqdm import tqdm

def get_default_project():
    _, project_id = google.auth.default()
    return project_id

def fetch_columns(client, project_id, dataset_id, table_id):
    """Fetch column names for a given table."""
    table_ref = client.get_table(f"{project_id}.{dataset_id}.{table_id}")
    table_type = table_ref.table_type
    return {
            'fields': [{"name": field.name, "type": field.field_type, 'mode': field.mode} for field in table_ref.schema],
            'table_type': table_type
        }

def fetch_tables(client, project_id, dataset_id):
    """Fetch tables and their columns for a given dataset."""
    tables_info = {}
    tables = list(client.list_tables(dataset_id))

    with ThreadPoolExecutor(max_workers=4) as executor:
        futures = {
            executor.submit(fetch_columns, client, project_id, dataset_id, table.table_id): table.table_id
            for table in tables
        }
        for future in tqdm(as_completed(futures), total=len(futures), desc=f"Fetching tables for {dataset_id}", leave=False):
            table_id = futures[future]
            tables_info[table_id] = future.result()

    return tables_info

def get_bq_project_structure(project_id):
    """Get the entire project structure with datasets, tables, and columns."""
    # Initialize a BigQuery client
    client = bigquery.Client(project=project_id)

    # Initialize an empty dictionary to store the project structure
    project_structure = {}

    # Get all datasets in the project
    datasets = list(client.list_datasets())

    with ThreadPoolExecutor(max_workers=4) as executor:
        futures = {
            executor.submit(fetch_tables, client, project_id, dataset.dataset_id): dataset.dataset_id
            for dataset in datasets
        }
        for future in tqdm(as_completed(futures), total=len(futures), desc="Fetching datasets"):
            dataset_id = futures[future]
            project_structure[dataset_id] = future.result()

    return project_structure

def search_bq_structure(structure, substring):
    """Search for a substring in table names and columns."""
    results = []

    def search_table_columns(dataset_id, table_id, columns):
        local_results = []
        # Search in table names
        if substring.lower() in table_id.lower():
            local_results.append(('TABLE', f"{dataset_id}.{table_id}"))
        # Search in column names
        for column in columns:
            if substring.lower() in column['name'].lower():
                local_results.append(('COLUMN', f"{dataset_id}.{table_id}.{column['name']}"))
        return local_results

    def search_dataset(dataset_id, tables):
        local_results = []
        with ThreadPoolExecutor() as executor:
            # tables is a dict of table_id -> {'fields': [...], 'table_type': ...}
            futures = {
                executor.submit(search_table_columns, dataset_id, table_id, table_data['fields']): table_id
                for table_id, table_data in tables.items()
            }
            for future in as_completed(futures):
                local_results.extend(future.result())
        return local_results

    with ThreadPoolExecutor() as executor:
        futures = {
            executor.submit(search_dataset, dataset_id, tables): dataset_id
            for dataset_id, tables in structure.items()
        }
        for future in tqdm(as_completed(futures), total=len(futures), desc="Searching"):
            results.extend(future.result())

    return results

@click.group()
def cli():
    pass

@cli.command()
@click.option('--project-id', default=None, help='GCP project ID')
@click.option('-o', '--output', default=None, help='Output file path. Must be json format. If not provided, will print to stdout.')
def refresh(output=None, project_id=None):
    if project_id is None:
        project_id = get_default_project()
    bq_structure = get_bq_project_structure(project_id)
    if output is not None:
        with open(output, 'w') as f:
            json.dump(bq_structure, f)
        click.echo(f"project structure of {project_id} saved to {output}")
    else:
        click.echo(json.dumps(bq_structure))

@cli.command()
@click.argument('search_term')
@click.option('-o', '--output', default=None, help='Output file path. Must be json format. If not provided, will print to stdout.')
@click.option('--cache-file', default='/tmp/bq_structure.json', help='Cache file for BQ structure')
def search(search_term, output=None, cache_file=None):
    project_id = get_default_project()
    
    try:
        with open(cache_file, 'r') as f:
            click.echo(f"using cache file {cache_file}")
            bq_structure = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        click.echo("cache file not found, refreshing...")
        bq_structure = get_bq_project_structure(project_id)
        with open(cache_file, 'w') as f:
            json.dump(bq_structure, f)

    search_results = search_bq_structure(bq_structure, search_term)
    if output is not None:
        with open(output, 'w') as f:
            json.dump(search_results, f)
        click.echo(f"search results saved to {output}")
    else:
        click.echo(json.dumps(search_results))

if __name__ == "__main__":
    cli()