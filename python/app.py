from flask import Flask
from datetime import datetime
import sys
import os

app = Flask(__name__)

def get_html_content():
    template_path = os.path.join(os.path.dirname(__file__), '../shared/templates/index.html')
    with open(template_path, 'r') as f:
        template = f.read()

    html = template \
        .replace('{{PLATFORM}}', 'Python (Flask)') \
        .replace('{{VERSION}}', sys.version.split()[0]) \
        .replace('{{TIMESTAMP}}', datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')) \
        .replace('{{CANVAS_LINK}}', '/python/canvas') \
        .replace('{{DOTNET_ACTIVE}}', '') \
        .replace('{{NODEJS_ACTIVE}}', '') \
        .replace('{{PYTHON_ACTIVE}}', 'active') \
        .replace('{{JAVA_ACTIVE}}', '') \
        .replace('{{GO_ACTIVE}}', '')

    return html

def get_canvas_content():
    template_path = os.path.join(os.path.dirname(__file__), '../shared/templates/canvas.html')
    with open(template_path, 'r') as f:
        template = f.read()

    return template.replace('{{PLATFORM}}', 'Python (Flask)')

@app.route('/')
@app.route('/python')
def hello():
    return get_html_content()

@app.route('/canvas')
@app.route('/python/canvas')
def canvas():
    return get_canvas_content()

@app.route('/join')
@app.route('/python/join')
def join():
    template_path = os.path.join(os.path.dirname(__file__), '../shared/templates/join.html')
    with open(template_path, 'r') as f:
        return f.read()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=False)
