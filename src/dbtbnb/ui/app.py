"""UI."""
# https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst
# https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst#label-analyst-access-example
# https://github.com/Snowflake-Labs/sf-samples/blob/main/samples/cortex-analyst/Advanced%20SiS%20Demo/Talk_to_your_data.py

from typing import Annotated, Literal

import httpx
import snowflake.connector as sc
import streamlit as st
from pydantic import BaseModel, Field

from dbtbnb.config import Config, get_config
from dbtbnb.logger import get_logger

config = get_config()
logger = get_logger(__name__)


class CortexAnalystResponse(BaseModel):
    """Snowflake Cortex Analyst API response."""

    class Message(BaseModel):  # noqa: D106
        class TextContent(BaseModel):  # noqa: D106
            type: Literal["text"]
            text: str

        class SQLContent(BaseModel):  # noqa: D106
            type: Literal["sql"]
            statement: str

        content: list[Annotated[TextContent | SQLContent, Field(discriminator="type")]]

    message: Message


@st.cache_resource
def get_sf_connection(config: Config) -> sc.SnowflakeConnection | None:
    """Get Snowflake connection."""
    logger.debug("Connecting to Snowflake")
    params = {
        "account": f"{config.sf_org}-{config.sf_account}",
        "user": config.sf_user,
        "authenticator": config.sf_authenticator,
        "private_key_file": config.sf_private_key_file_path.expanduser(),
        "role": config.sf_role,
        "warehouse": config.sf_warehouse,
        "database": config.sf_database,
        "schema": config.sf_schema,
    }
    try:
        conn = sc.connect(**params)
        return conn
    except sc.errors.Error as err:
        logger.error("Could not connect to database: %s", err)
        st.error(f"Could not connect to database: {err}")
        st.stop()


def get_cortex_analyst_response(
    conn: sc.SnowflakeConnection, messages, semantic_model: str
) -> CortexAnalystResponse:
    """Get response from Snowflake Cortex Analyst."""
    logger.debug("Getting response from Cortex Analyst")
    with httpx.Client() as client:
        response = client.post(
            url=f"https://{conn.host}/api/v2/cortex/analyst/message",
            headers={
                "Authorization": f"Snowflake Token={conn.rest.token}",
                "Content-Type": "application/json",
            },
            json={"messages": messages, "semantic_model": semantic_model},
            timeout=60,
        )
        response.raise_for_status()

        return CortexAnalystResponse(**response.json())


def parse_cortex_analyst_response(response_data: CortexAnalystResponse) -> str:
    """Parse Snowflake Cortex Analyst response."""
    full_response = ""

    logger.debug("Parsing response")
    for item in response_data.message.content:
        if item.type == "text":
            full_response += item.text + "\n\n"
        elif item.type == "sql":
            full_response += f"```sql\n{item.statement}\n```\n\n"

    return full_response.strip()


st.title("dbtbnb analyzer")

if "messages" not in st.session_state:
    st.session_state.messages = []


for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

if prompt := st.chat_input("Ask me anything"):
    with st.chat_message(name="user"):
        st.markdown(prompt)
    st.session_state.messages.append({"role": "user", "content": prompt})

    with st.chat_message(name="assistant"):
        with st.spinner("Thinking..."):
            try:
                conn = get_sf_connection(config)
                response = get_cortex_analyst_response(
                    conn=conn,  # type: ignore
                    messages=st.session_state.messages,
                    semantic_model=config.sf_semantic_model,
                )
                parsed_response = parse_cortex_analyst_response(response)

                st.markdown(parsed_response)
                st.session_state.messages.append({"role": "assistant", "content": parsed_response})

            except httpx.HTTPError as err:
                logger.error("Could not get response: %s", err)
                st.error(f"Error: Could not get response from Cortex Analyst: {err}")
