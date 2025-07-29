from flask import Flask, request, render_template_string, send_from_directory, abort, session
import os
from os.path import dirname
import bcrypt
from werkzeug.utils import secure_filename
from datetime import datetime
from pathlib import Path
import hashlib

app = Flask(__name__)

def binarycheck(filepath, blocksize=512):
    try:
        with open(filepath, 'rb') as f:
            block = f.read(blocksize)
            if b'\0' in block:
                return True
    except Exception:
        return True
    return False

def gethashpass():
    pw = os.environ.get("readpassword")
    if not pw:
        raise RuntimeError("password not set")
    pw_bytes = pw.encode()
    hashed_pw = bcrypt.hashpw(pw_bytes, bcrypt.gensalt())
    secret_key = hashlib.sha256(pw_bytes).digest()
    return hashed_pw, secret_key

passhash, secret_key = gethashpass()
app.secret_key = secret_key

def getlang(path):
    ext = Path(path).suffix.lower().lstrip(".")
    return {
        "sh": "shell",
        "py": "python",
        "js": "javascript",
        "ts": "typescript",
        "json": "json",
        "html": "html",
        "css": "css",
        "md": "markdown",
        "java": "java",
        "c": "c",
        "cpp": "cpp",
        "xml": "xml",
        "yml": "yaml",
        "yaml": "yaml",
        "go": "go",
        "rs": "rust",
        "php": "php",
        "sql": "sql",
        "ini": "ini",
    }.get(ext, "plaintext")

def validpass(pw):
    return bcrypt.checkpw(pw.encode(), passhash)

def passprompt(message="Please enter the password"):
    return f'''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Aurora File Transfer - Login</title>
        <link rel="stylesheet" href="/static/style.css">
    </head>
    <body>
        <h2>{message}</h2>
        <form method="post">
            <input type="password" name="password" placeholder="Password" required autofocus>
            <input type="submit" value="Submit">
        </form>
    </body>
    </html>
    '''

@app.route("/", methods=["GET", "POST"])
def main():
    if request.method == "POST":
        pw = request.form.get("password", "")
        if validpass(pw):
            session['authenticated'] = True
            return browse("", pw)
        else:
            return passprompt("Invalid password, try again")
    return passprompt()
def check_auth():
    if not session.get('authenticated'):
        return False
    return True
    
@app.route("/logout")
def logout():
    session.clear()
    return passprompt("Logged out. Please login again.")

@app.route("/browse/", defaults={"path": ""}, methods=["GET", "POST"])
@app.route("/browse/<path:path>", methods=["GET", "POST"])
def browse(path, password=None):
    if not check_auth():
        return passprompt("Authentication required")
    now = datetime.now().strftime("%H:%M %b %d")

    fullpath = os.path.join("/", path)
    if not os.path.exists(fullpath):
        abort(404)

    if os.path.isfile(fullpath):
        return send_from_directory(os.path.dirname(fullpath), os.path.basename(fullpath))

    items = []
    items.append({"name": "./", "path": path, "is_dir": True})
    parentpath = os.path.normpath(os.path.join(path, ".."))
    if parentpath == ".":
        parentpath = ""
    items.append({"name": "../", "path": parentpath, "is_dir": True})

    try:
        entries = os.listdir(fullpath)
    except PermissionError:
        entries = []

    for entry in sorted(entries):
        if entry in (".", ".."):
            continue
        entrypath = os.path.join(path, entry)
        entrypathfull = os.path.join(fullpath, entry)
        is_dir = os.path.isdir(entrypathfull)
        is_binary = False
        if not is_dir:
            is_binary = binarycheck(entrypathfull)
        items.append({
            "name": entry,
            "path": entrypath,
            "is_dir": is_dir,
            "is_binary": is_binary
        })

    return render_template_string('''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Aurora File Transfer - GGP</title>
        <link rel="stylesheet" href="/static/style.css">
    </head>
    <body>

        <h1>Aurora File Transfer - GGP</h1>
        <form id="upload-form" enctype="multipart/form-data" method="post" action="/upload/{{path}}">
            <ul>
                <li>
                    <input type="file" name="file" id="file-input" required>
                    <label for="file-input">Upload a File</label>
                </li>
            </ul>
        </form>

        <pre class="ps1">Aurora <span class="time">{{current_time}}</span> <span class="path">/{{path}}/</span> ls -a</pre>

        <div class="file-list" role="list">
        {% for item in items %}
        <a href="{% if item.is_dir %}/browse/{{item.path}}{% elif not item.is_binary %}/edit/{{item.path}}{% else %}/browse/{{item.path}}{% endif %}" role="listitem" class="{% if item.is_dir %}dir{% elif not item.is_binary %}file{% endif %}">{{ item.name }}{{ '/' if item.is_dir and not item.name.endswith('/') else '' }}</a>
        {% endfor %}
        </div>
        <pre class="ps1">Aurora <span class="time">{{current_time}}</span> <span class="path">/{{path}}/</span></pre>
        <pre id="upload-status"></pre>

        <script>
        const form = document.getElementById('upload-form');
        const status = document.getElementById('upload-status');
        const fileInput = document.getElementById('file-input');

        function uploadFile() {
            status.textContent = '';
            if (!fileInput.files.length) {
                status.textContent = 'No file selected.\\n';
                return;
            }
            const file = fileInput.files[0];
            const password = form.querySelector('input[name="password"]').value;

            const xhr = new XMLHttpRequest();
            xhr.open('POST', form.action);

            xhr.upload.onprogress = function(event) {
                if (event.lengthComputable) {
                    const percent = Math.floor((event.loaded / event.total) * 100);
                    const barLength = 20;
                    const filledLength = Math.floor(barLength * percent / 100);
                    const bar = '='.repeat(filledLength) + (filledLength < barLength ? '>' : '') + ' '.repeat(barLength - filledLength - (filledLength < barLength ? 1 : 0));
                    status.textContent = `Uploading: ${percent}% [${bar}]`;
                }
            };

            xhr.onload = function() {
                if (xhr.status === 200) {
                    status.textContent = `Upload complete`;
                } else {
                    status.textContent = `Upload failed with status ${xhr.status}`;
                }
            };

            const formData = new FormData();
            formData.append('file', file);
            formData.append('password', password);

            xhr.send(formData);
        }

        fileInput.addEventListener('change', function() {
            if (fileInput.files.length > 0) {
                uploadFile();
            }
        });
        </script>
    </body>
    </html>
    ''', path=path, password=password, items=items, current_time=now)

@app.route("/edit/<path:path>", methods=["GET", "POST"])
def edit(path):
    if not check_auth():
        return passprompt("Authentication required")

    fullpath = os.path.join("/", path)
    if not os.path.exists(fullpath) or not os.path.isfile(fullpath):
        abort(404)

    if request.method == "POST":
        action = request.form.get("action", "save")
        content = request.form.get("content", "")
        try:
            with open(fullpath, "w", encoding="utf-8") as f:
                f.write(content)
            if action == "save_exit":
                return f'<script>window.location.href="/browse/{dirname(path)}";</script>'
            return "", 204
        except Exception as e:
            return f'Error saving file: {e}', 500

    try:
        with open(fullpath, "r", encoding="utf-8") as f:
            filecontent = f.read()
    except Exception as e:
        filecontent = f"Error reading file: {e}"

    language = getlang(path)
    pathdir = dirname(path)

    return render_template_string('''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Editing {{ path }}</title>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/vs/loader.min.js"></script>
        <script>
        require.config({ paths: { 'vs': 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/vs' }});
        </script>
        <link rel="stylesheet" href="/static/style.css">
    </head>
    <body>
        <div class="topbar">
            <button onclick="submitForm('save')">Save</button>
            <button onclick="submitForm('save_exit')">Save & Exit</button>
            <button onclick="exitWithoutSaving()">Exit Without Saving</button>
            <span style="margin-left:auto;">
            {%- set parts = path.strip('/').split('/') -%}
            {%- set cumulative_path = '' -%}
            <a href="/browse/">/</a>
            {%- for part in parts[:-1] %}
                {%- set cumulative_path = cumulative_path + '/' + part -%}
                <a href="/browse{{ cumulative_path }}">{{ part }}</a> /
            {%- endfor %}
            {{ parts[-1] }}
            </span>
        </div>

        <form id="editor-form" method="post" style="display:none;">
            <input type="hidden" name="content" id="content-input">
            <input type="hidden" name="action" id="form-action" value="save">
        </form>

        <div id="editor"></div>

        <script>
        let editor;

        require(["vs/editor/editor.main"], function () {
            editor = monaco.editor.create(document.getElementById("editor"), {
                value: {{ filecontent | tojson }},
                language: "{{ language }}",
                theme: "vs-dark",
                automaticLayout: true
            });

            window.addEventListener("keydown", function(e) {
                if ((e.ctrlKey || e.metaKey) && e.key === 's') {
                    e.preventDefault();
                    submitForm('save');
                }
            });
        });

        function submitForm(action) {
            const input = document.getElementById("content-input");
            const form = document.getElementById("editor-form");
            const formAction = document.getElementById("form-action");
            input.value = editor.getValue();
            formAction.value = action;
            form.submit();
        }

        function exitWithoutSaving() {
            window.location.href = "/browse/{{ pathdir }}";
        }
        </script>
    </body>
    </html>
    ''', path=path, password=pw, filecontent=filecontent, language=language, pathdir=pathdir)

@app.route("/upload/<path:path>", methods=["POST"])
def upload(path):
    if not check_auth():
        return passprompt("Authentication required")

    fullpath = os.path.join("/", path)
    file = request.files.get("file")
    if file:
        filename = secure_filename(file.filename)
        file.save(os.path.join(fullpath, filename))
    return '', 204

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=6969)
