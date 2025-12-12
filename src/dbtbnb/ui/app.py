"""UI."""

from typing import Annotated, Any, Literal

import httpx
import snowflake.connector as sc
import streamlit as st
from pydantic import BaseModel, Field

from dbtbnb.config import Config, get_config
from dbtbnb.logger import get_logger
from dbtbnb.utils import get_fingerprint, get_jwt

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

        class SuggestionsContent(BaseModel):  # noqa: D106
            type: Literal["suggestions"]
            suggestions: list[str]

        content: list[
            Annotated[TextContent | SQLContent | SuggestionsContent, Field(discriminator="type")]
        ]

    message: Message


class ParsedResponse(BaseModel):
    """Parsed response from Cortex Analyst."""

    response: str
    text: str
    sql: str | None
    suggestions: str | None


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


@st.cache_resource
def get_token(config: Config):
    """Get token to authenticate with Snowflake."""
    logger.debug("Generating fingerprint")
    fingerprint = get_fingerprint(config.sf_private_key_file_path)

    logger.debug("Generating JWT")
    token = get_jwt(
        sf_org=config.sf_org,
        sf_account=config.sf_account,
        sf_user=config.sf_user,
        sf_private_key_file_path=config.sf_private_key_file_path,
        fingerprint=fingerprint,
    )

    return token


def get_cortex_analyst_response(
    conn: sc.SnowflakeConnection, token: str, messages, semantic_view: str
) -> CortexAnalystResponse:
    """Get response from Snowflake Cortex Analyst."""
    logger.debug("Getting response from Cortex Analyst")
    with httpx.Client() as client:
        response = client.post(
            url=f"https://{conn.host}/api/v2/cortex/analyst/message",
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json",
                "X-Snowflake-Authorization-Token-Type": "KEYPAIR_JWT",
            },
            json={"messages": messages, "semantic_view": semantic_view},
            timeout=60,
        )
        response.raise_for_status()

        return CortexAnalystResponse(**response.json())


def parse_cortex_analyst_response(response_data: CortexAnalystResponse) -> ParsedResponse:
    """Parse Snowflake Cortex Analyst response."""
    full_response = ""
    text = ""
    sql = ""
    suggestions = ""

    logger.debug("Parsing response")
    for item in response_data.message.content:
        match item.type:
            case "text":
                full_response += item.text + "\n\n"
                text += item.text
            case "sql":
                full_response += f"```sql\n{item.statement}\n```\n\n"
                sql += item.statement
            case "suggestion":
                suggestions = "\n".join(f"-{s}" for s in item.suggestions)
                full_response += f"Suggestions:\n{suggestions}\n\n"

    return ParsedResponse(
        response=full_response.strip(), text=text, sql=sql, suggestions=suggestions
    )


def execute_query(conn: sc.SnowflakeConnection, sql: str):
    """Execute SQL query."""
    cursor = conn.cursor()
    logger.debug("Executing query")
    cursor.execute(sql)
    logger.debug("Fetching results")
    df = cursor.fetch_pandas_all()
    logger.debug("Result contains %s rows and %s cols", df.shape[0], df.shape[1])

    return df


def format_parsed_response_for_history(parsed_response: ParsedResponse) -> dict[str, Any]:
    """Format parsed response for message history."""
    result = {
        "role": "analyst",
        "content": [
            {"type": "text", "text": parsed_response.text},
        ],
    }
    if parsed_response.sql:
        result["content"].append({"type": "sql", "statement": parsed_response.sql})

    return result


st.title("dbtbnb analyzer")

if "messages" not in st.session_state:
    st.session_state.messages = []


for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

if prompt := st.chat_input("Ask me anything"):
    with st.chat_message(name="user"):
        st.markdown(prompt)
    st.session_state.messages.append(
        {"role": "user", "content": [{"type": "text", "text": prompt}]}
    )

    with st.chat_message(name="assistant"):
        with st.spinner("Thinking..."):
            try:
                conn = get_sf_connection(config)
                token = get_token(config)
                response = get_cortex_analyst_response(
                    conn=conn,  # type: ignore
                    token=token,
                    messages=st.session_state.messages,
                    semantic_view=config.sf_semantic_view,
                )
                parsed_response = parse_cortex_analyst_response(response)
                st.markdown("### Response")
                st.markdown(parsed_response.response)

                if parsed_response.sql:
                    result = execute_query(conn=conn, sql=parsed_response.sql)  # type: ignore
                    st.markdown("### Result")
                    st.dataframe(result)

                formatted_response = format_parsed_response_for_history(parsed_response)
                logger.debug(formatted_response)
                st.session_state.messages.append(formatted_response)

            except httpx.HTTPStatusError as err:
                logger.error("Could not get response: %s", err)
                logger.error("Error details: %s", err.response.text)
                st.error(f"Error: Could not get response from Cortex Analyst: {err}")
