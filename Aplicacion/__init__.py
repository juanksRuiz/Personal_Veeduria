# -*- coding: utf-8 -*-
import os
from flask import Flask

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
import smtplib

# Constantes globales
ROLES = ["administrador","veedor"]

#Variables globales
app = Flask(__name__)
conn = None
cur = None
# user session management
login_manager = flask_login.LoginManager()


def init_app():
    global app
    global conn
    global cur
    global login_manager

    # Connection to Database using pgadmin
    conn = psycopg2.connect(
        user="postgres",
        password="postgres",
        host="localhost",
        port="5432",
        dbname="Datos_Veeduria"
    )
    conn.set_session(autocommit=True)
    cur = conn.cursor()
    # configuracion de seguridad
    app.secret_key = secrets.token_bytes(nbytes=16)
    # inicia app
    login_manager.init_app(app)

class Usuario(flask_login.UserMixin):
    def __init__(self, usuario_id, usuario_tipo):
        self.id = usuario_id
        self.u_tipo = usuario_tipo
    
    def get_usuario_tipo(self):
        return self.u_tipo

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

def generate_passwd():
    """
    Genera contraseña aleatoria para los usuarios que olvidan su contraseña
    RETORNA:
        passwd: contraseña aleatoria
    """
    longitud = 8
    valores = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<=>@#%&+"
    passwd = "".join([choice(valores) for i in range(longitud)])
    return passwd

def send_email(username, email, codigo):
    """
    Envía un correo a un usuario determinado con una contraseña temporal para el
    inicio de sesión
    PARAMETROS:
         username: nombre de usuario
        email: correo del usuario
        código: código del usuario que corresponde a la contraseña temporal
    """
    sender_email = "EpsilonAppUR@gmail.com"
    receiver_email = email
    password = "macc123*"
#app.before_first_request(init_app)
@app.route("/")
def main():
    return "Lo lograste"


if __name__ == '__main__':
    # debug es para que en caso de hacer cambios en codigo que el servidor se actualice
    app.run(host="127.0.0.1",port = 3000,debug = True)
