"""Dagster definitions."""

from dagster import Definitions
from dagster_dbt import DbtCliResource

from .assets import dbtbnb_dbt_assets
from .project import dbtbnb_project
from .schedules import schedules

defs = Definitions(
    assets=[dbtbnb_dbt_assets],
    schedules=schedules,
    resources={
        "dbt": DbtCliResource(project_dir=dbtbnb_project),
    },
)
