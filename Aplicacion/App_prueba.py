# -*- coding: utf-8 -*-
import os
from flask import Flask
import json
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
#conn = None
#cur = None
# user session management
login_manager = flask_login.LoginManager()


#def init_app():
#global app
#global conn
#global cur
#    global login_manager

# Connection to Database using pgadmin
conn = psycopg2.connect(
    user="postgres",
    password="postgres",
    host="localhost",
    port="5432",
    dbname="Datos_Veeduria",
    )


#conn.set_session(autocommit=True)
#cur = conn.cursor()
# configuracion de seguridad
#app.secret_key = secrets.token_bytes(nbytes=16)
# inicia app
#login_manager.init_app(app)

#app.before_first_request(init_app)


if __name__ == '__main__':
    # debug es para que en caso de hacer cambios en codigo que el servidor se actualice
    app.run(host="127.0.0.1",port = 3000,debug = True)
