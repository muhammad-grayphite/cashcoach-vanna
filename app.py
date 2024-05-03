import logging

from dotenv import load_dotenv
from functools import wraps
from flask import jsonify, Response, request, Flask, render_template
import flask
import os

from vanna.chromadb import ChromaDB_VectorStore
from vanna.openai import OpenAI_Chat

from cache import MemoryCache
from constants import DB_DOCUMENTATION

load_dotenv()


class MyVanna(ChromaDB_VectorStore, OpenAI_Chat):

    def __init__(self, config=None,
                 allow_llm_to_see_data=False,
                 logo="https://img.vanna.ai/vanna-flask.svg",
                 title="Welcome to Vanna.AI",
                 subtitle="Your AI-powered copilot for SQL queries.",
                 show_training_data=True,
                 suggested_questions=True,
                 sql=True,
                 table=True,
                 csv_download=True,
                 chart=True,
                 redraw_chart=True,
                 auto_fix_sql=True,
                 ask_results_correct=True,
                 followup_questions=True,
                 summarization=True
                 ):
        """
        Expose a Flask app that can be used to interact with a Vanna instance.

        Args:
            allow_llm_to_see_data: Whether to allow the LLM to see data. Defaults to False.
            logo: The logo to display in the UI. Defaults to the cashcoach logo.
            title: The title to display in the UI. Defaults to "Welcome to CashCoach".
            subtitle: The subtitle to display in the UI. Defaults to "Your AI-powered copilot for SQL queries.".
            show_training_data: Whether to show the training data in the UI. Defaults to True.
            suggested_questions: Whether to show suggested questions in the UI. Defaults to True.
            sql: Whether to show the SQL input in the UI. Defaults to True.
            table: Whether to show the table output in the UI. Defaults to True.
            csv_download: Whether to allow downloading the table output as a CSV file. Defaults to True.
            chart: Whether to show the chart output in the UI. Defaults to True.
            redraw_chart: Whether to allow redrawing the chart. Defaults to True.
            auto_fix_sql: Whether to allow auto-fixing SQL errors. Defaults to True.
            ask_results_correct: Whether to ask the user if the results are correct. Defaults to True.
            followup_questions: Whether to show followup questions. Defaults to True.
            summarization: Whether to show summarization. Defaults to True.

        Returns:
            None
        """

        ChromaDB_VectorStore.__init__(self, config=config)
        OpenAI_Chat.__init__(self, config=config)
        self.allow_llm_to_see_data = allow_llm_to_see_data
        self.logo = logo
        self.title = title
        self.subtitle = subtitle
        self.show_training_data = show_training_data
        self.suggested_questions = suggested_questions
        self.sql = sql
        self.table = table
        self.csv_download = csv_download
        self.chart = chart
        self.redraw_chart = redraw_chart
        self.auto_fix_sql = auto_fix_sql
        self.ask_results_correct = ask_results_correct
        self.followup_questions = followup_questions
        self.summarization = summarization

        logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


vn = MyVanna(
    config={'api_key': os.environ['API_KEY'], 'model': os.environ['MODEL']},
    title="CashCoach",
    subtitle="Expense tracking and budgeting system",
    allow_llm_to_see_data=True,
    logo="static/cashcoach-logo.svg"
)

cache = MemoryCache()

vn.connect_to_postgres(
    host=os.environ['PG_HOST'],
    dbname=os.environ['PG_DATABASE'],
    user=os.environ['PG_USERNAME'],
    password=os.environ['PG_PASSWORD'],
    port=int(os.environ['PG_PORT']),
)

app = Flask(__name__)


def requires_cache(fields):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            id = request.args.get('id')

            if id is None:
                return jsonify({"type": "error", "error": "No id provided"})

            for field in fields:
                if cache.get(id=id, field=field) is None:
                    return jsonify({"type": "error", "error": f"No {field} found"})

            field_values = {field: cache.get(id=id, field=field) for field in fields}

            # Add the id to the field_values
            field_values['id'] = id

            return f(*args, **field_values, **kwargs)

        return decorated

    return decorator


@app.route('/api/v0/generate_questions', methods=['GET'])
def generate_questions():
    return jsonify({
        "type": "question_list",
        "questions": vn.generate_questions(),
        "header": "Here are some questions you can ask:"
    })


@app.route('/api/v0/generate_sql', methods=['GET'])
def generate_sql():
    question = flask.request.args.get('question')
    user_id = flask.request.args.get('userId')

    if question is None:
        return jsonify({"type": "error", "error": "No question provided"})

    id = cache.generate_id(question=question)
    sql = vn.generate_sql(question=question)

    if not (sql.startswith("with") or sql.startswith("With") or sql.startswith("SELECT") or sql.startswith("WITH")):
        return jsonify({"type": "error", "error": str(sql)})

    cache.set(id=id, field='question', value=question)
    cache.set(id=id, field='sql', value=sql)

    if not (user_id.strip() == '' or user_id == 'undefined'):
        sql = sql.replace(":user_id", f"'{user_id.strip()}'")

    return jsonify(
        {
            "type": "sql",
            "id": id,
            "text": sql,
        })


@app.route('/api/v0/update_sql', methods=['POST'])
def update_sql():
    sql = flask.request.json.get('sql')
    id = flask.request.json.get('id')

    if sql is None:
        return jsonify({"type": "error", "error": "No sql provided"})

    cache.set(id=id, field='sql', value=sql)

    return jsonify(
        {
            "type": "sql",
            "id": id,
            "text": sql,
        })


@app.route('/api/v0/run_sql', methods=['GET'])
@requires_cache(['sql'])
def run_sql(id: str, sql: str):
    try:
        user_id = flask.request.args.get('userId')
        if user_id:
            if not (user_id.strip() == '' or user_id == 'undefined'):
                sql = sql.replace(":user_id", f"'{user_id.strip()}'")

        df = vn.run_sql(sql=sql)

        cache.set(id=id, field='df', value=df)

        return jsonify(
            {
                "type": "df",
                "id": id,
                "df": df.head(10).to_json(orient='records'),
            })

    except Exception as e:
        return jsonify({"type": "error", "error": str(e)})


@app.route('/api/v0/download_csv', methods=['GET'])
@requires_cache(['df'])
def download_csv(id: str, df):
    csv = df.to_csv()

    return Response(
        csv,
        mimetype="text/csv",
        headers={"Content-disposition":
                     f"attachment; filename={id}.csv"})


@app.route('/api/v0/generate_plotly_figure', methods=['GET'])
@requires_cache(['df', 'question', 'sql'])
def generate_plotly_figure(id: str, df, question, sql):
    try:
        code = vn.generate_plotly_code(question=question, sql=sql,
                                       df_metadata=f"Running df.dtypes gives:\n {df.dtypes}")
        fig = vn.get_plotly_figure(plotly_code=code, df=df, dark_mode=False)
        fig_json = fig.to_json()

        cache.set(id=id, field='fig_json', value=fig_json)

        return jsonify(
            {
                "type": "plotly_figure",
                "id": id,
                "fig": fig_json,
            })
    except Exception as e:
        # Print the stack trace
        import traceback
        traceback.print_exc()

        return jsonify({"type": "error", "error": str(e)})


@app.route("/api/v0/generate_summary", methods=["GET"])
@requires_cache(["df", "question"])
def generate_summary(id: str, df, question):
    if vn.allow_llm_to_see_data:
        summary = vn.generate_summary(question=question, df=df)

        cache.set(id=id, field="summary", value=summary)

        return jsonify(
            {
                "type": "text",
                "id": id,
                "text": summary,
            }
        )
    else:
        return jsonify(
            {
                "type": "text",
                "id": id,
                "text": "Summarization can be enabled if you set allow_llm_to_see_data=True",
            }
        )


@app.route('/api/v0/get_training_data', methods=['GET'])
def get_training_data():
    df = vn.get_training_data()

    return jsonify(
        {
            "type": "df",
            "id": "training_data",
            "df": df.head(25).to_json(orient='records'),
        })


@app.route('/api/v0/remove_training_data', methods=['POST'])
def remove_training_data():
    # Get id from the JSON body
    id = flask.request.json.get('id')

    if id is None:
        return jsonify({"type": "error", "error": "No id provided"})

    if vn.remove_training_data(id=id):
        return jsonify({"success": True})
    else:
        return jsonify({"type": "error", "error": "Couldn't remove training data"})


@app.route('/api/v0/train', methods=['POST'])
def add_training_data():
    question = flask.request.json.get('question')
    sql = flask.request.json.get('sql')
    ddl = flask.request.json.get('ddl')
    documentation = flask.request.json.get('documentation')

    try:
        id = vn.train(question=question, sql=sql, ddl=ddl, documentation=documentation)

        return jsonify({"id": id})
    except Exception as e:
        print("TRAINING ERROR", e)
        return jsonify({"type": "error", "error": str(e)})


@app.route('/api/v0/generate_followup_questions', methods=['GET'])
@requires_cache(['df', 'question', 'sql'])
def generate_followup_questions(id: str, df, question, sql):
    followup_questions = vn.generate_followup_questions(question=question, sql=sql, df=df)

    cache.set(id=id, field='followup_questions', value=followup_questions)

    return jsonify(
        {
            "type": "question_list",
            "id": id,
            "questions": followup_questions,
            "header": "Here are some followup questions you can ask:"
        })


@app.route('/api/v0/load_question', methods=['GET'])
@requires_cache(['question', 'sql', 'df', 'fig_json', 'followup_questions'])
def load_question(id: str, question, sql, df, fig_json, followup_questions):
    try:
        return jsonify(
            {
                "type": "question_cache",
                "id": id,
                "question": question,
                "sql": sql,
                "df": df.head(10).to_json(orient='records'),
                "fig": fig_json,
                "followup_questions": followup_questions,
            })

    except Exception as e:
        return jsonify({"type": "error", "error": str(e)})


@app.route('/api/v0/get_question_history', methods=['GET'])
def get_question_history():
    return jsonify({"type": "question_history", "questions": cache.get_all(field_list=['question'])})


@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def root(path: str):
    return render_template('index.html')


@app.route("/api/v0/get_config", methods=["GET"])
def get_config():
    config = {
        "logo": vn.logo,
        "title": vn.title,
        "subtitle": vn.subtitle,
        "show_training_data": vn.show_training_data,
        "suggested_questions": vn.suggested_questions,
        "sql": vn.sql,
        "table": vn.table,
        "csv_download": vn.csv_download,
        "chart": vn.chart,
        "redraw_chart": vn.redraw_chart,
        "auto_fix_sql": vn.auto_fix_sql,
        "ask_results_correct": vn.ask_results_correct,
        "followup_questions": vn.followup_questions,
        "summarization": vn.summarization,
    }

    return jsonify(
        {
            "type": "config",
            "config": config
        }
    )


def check_or_create_training_data() -> None:
    df = vn.get_training_data()
    data = df.head(25).to_json(orient='records')

    if data == '[]':
        vn.train(documentation=DB_DOCUMENTATION)
        schema = ""
        with open("./cashcoach_schema.sql", "r") as file:
            schema = file.read()

        if len(schema) > 1:
            vn.train(ddl=schema)
            logging.info("Model is trained, success")

        else:
            logging.warning("Schema file is empty!")
    else:
        logging.info("Model training dataset is Already loaded.")


with app.app_context():
    check_or_create_training_data()


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
