"""UI."""
# https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst
# https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst#label-analyst-access-example
# https://github.com/Snowflake-Labs/sf-samples/blob/main/samples/cortex-analyst/Advanced%20SiS%20Demo/Talk_to_your_data.py

from typing import Literal

import httpx
import snowflake.connector as sc
import streamlit as st
from pydantic import BaseModel, Field
from snowflake.connector.errors import Error as SFError

from ..config import Config, get_config

config = get_config()


class CortexAnalystResponse(BaseModel):
    """Snowflake Cortex Analyst API response."""

    class Message(BaseModel):  # noqa: D106
        class TextContent(BaseModel):  # noqa: D106
            type: Literal["text"]
            text: str

        class SQLContent(BaseModel):  # noqa: D106
            type: Literal["sql"]
            statement: str

        content: list[TextContent | SQLContent] = Field(..., discriminator="type")

    message: Message


@st.cache_resource
def get_sf_connection(config: Config) -> sc.SnowflakeConnection:
    """Get Snowflake connection."""
    params = {
        "account": config.sf_account,
        "user": config.sf_user,
        "authenticator": config.sf_authenticator,
        "private_key_file": config.sf_private_key_file_path,
        "warehouse": config.sf_warehouse,
        "database": config.sf_database,
        "schema": config.sf_schema,
    }
    conn = sc.connect(**params)

    return conn


def get_cortex_analyst_response(conn: sc.SnowflakeConnection, messages) -> CortexAnalystResponse:
    """Get response from Snowflake Cortex Analyst."""
    with httpx.Client() as client:
        response = client.post(
            url=f"https://{conn.host}/api/v2/cortex/analyst/message",
            headers={"Authorization": f"Snowflake Token={conn.rest.token}"},
            json={"messages": messages},
            timeout=60,
        )
        response.raise_for_status()

        return CortexAnalystResponse(**response.json())


def parse_cortex_analyst_response(response_data: CortexAnalystResponse) -> str:
    """Parse Snowflake Cortex Analyst response."""
    full_response = ""

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
                    conn=conn, messages=st.session_state.messages
                )
                parsed_response = parse_cortex_analyst_response(response)

                st.markdown(parsed_response)
                st.session_state.messages.append({"role": "assistant", "content": parsed_response})

            except SFError as err:
                st.error(f"Error: Could not get response from Cortex Analyst: {err}")
