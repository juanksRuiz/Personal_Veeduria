# -*- coding: utf-8 -*-

# Standard library imports
from random import choice
from functools import wraps

# Third party imports
from flask import flash, Flask, redirect, render_template, request, url_for
from markupsafe import escape
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import flask_login
import psycopg2
import secrets


# Constantes globales
ROLES = ["administrador","veedor"]

#Variables globales
app = Flask(__name__)
conn = None
cur = None
login_manager = flask_login.LoginManager()


def init_app():
    global app
    global conn
    global cur
    global login_manager

    # Connection to Database
    conn = psycopg2.connect(
        user="postgres",
        password="123",
        host="localhost",
        port="5432",
        database="epsilon",
        )

    conn.set_session(autocommit=True)
    cur = conn.cursor()
    app.secret_key = secrets.token_bytes(nbytes=16)
    login_manager.init_app(app)

app.before_first_request(init_app)


class Usuario(flask_login.UserMixin):
    def __init__(self, usuario_id, usuario_rol):
        self.id = usuario_id
        self.urol = usuario_rol
    
    def get_urol(self):
        return self.urol

@login_manager.user_loader
def load_user(user_id):
    """
    Carga una instancia de usuario a partir de su nombre de usuario.
    PARAMETROS:
        user_id: nombre de usuario
    RETORNA:
        instancia de un usuario
    """
    try:
        cur.execute("SELECT usuario FROM personas WHERE usuario=%s", (user_id,))
        cur.execute("SELECT tipo FROM personas WHERE usuario=%s", (user_id,))
        user_type = str(cur.fetchone()[0])
        return Usuario(user_id, user_type)
    except Exception:
        return None

def login_required(role="ANY"):
    def wrapper(fn):
        """
        Determina si el rol de un usuario permite o no acceder
        a la función donde se encuentra este wrapper.
        PARAMETROS:
            role: rol que requiere la función
        RETORNA:
            wrapper: wrapper dependiendo del rol
        """
        @wraps(fn)
        def decorated_view(*args, **kwargs):
            if not flask_login.current_user.is_authenticated:
                return app.login_manager.unauthorized()
            urole = flask_login.current_user.get_urole()
            if role != "ANY" and ROLES.index(urole) < ROLES.index(role):
                return app.login_manager.unauthorized()
            return fn(*args, **kwargs)
        return decorated_view
    return wrapper
#--------------------------------------
@app.route('/')
def Index():
    return "Hello world"


@app.route("/add_contact")
def add_contact():
    return "add contact"

@app.route("/edit")
def edit_contact():
    return "edit contact"

@app.route("/delete")
def delete_contact():
    return "borrar contacto"

# Cuando recibe argumentos
@app.route("/user/<username>")
def show_user_profile(username):
    # show the user profile or that user
    return "User %s" % escape(username)

# Especificando el tipo
@app.route("/post/<int:post_id>")
def show_post(post_id):
    return 'Post %d' % post_id


@app.route("/user/<username>")
def profile(username):
    return "{}\'s profile".format(escape(username))

# Especificando metodos de HTML para acceder a info
# por defecto solo reconoce GET
"""
@app.route('/login', methods=["GET","POST"])
def login():
    if request.method == "POST":
        return do_the_login()
    else:
        return show_the_login_form()
"""
#@app.route("/hello/")
#@app.route("/hello/<name>")
#def hello(name=None):
#    return render_template("hello.html", name=name)

@app.route("/home")
def home():
    return render_template("home.html")

# imprime url para una funcion
"""
with app.test_request_context():
    print(url_for("Index"))
    #print(url_for('login'))
    #print(url_for('login', next='/'))
    print(url_for('profile', username='John Doe'))
"""    
    
if __name__ == '__main__':
    # debug es para que en caso de hacer cambios en codigo que el servidor se actualice
    app.run(host="127.0.0.1",port = 3000,debug = True)
    
    
    