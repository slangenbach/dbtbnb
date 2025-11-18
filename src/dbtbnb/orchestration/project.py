"""Dagster project."""

from dagster_dbt import DbtProject

from ..constants import ROOT_PATH

dbtbnb_project = DbtProject(
    project_dir=ROOT_PATH.joinpath("analytics", "dbtbnb").resolve(),
)
dbtbnb_project.prepare_if_dev()
