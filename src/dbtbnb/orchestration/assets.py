"""Dagster assets."""

from dagster import AssetExecutionContext
from dagster_dbt import DbtCliResource, dbt_assets

from .project import dbtbnb_project


@dbt_assets(manifest=dbtbnb_project.manifest_path)
def dbtbnb_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):  # noqa: D103
    yield from dbt.cli(["build"], context=context).stream()
