# -*- coding: utf-8 -*-

# Archivo principal para poder arrancar la aplicación
from flask import Flask, url_for, request, render_template
from markupsafe import escape

app = Flask(__name__)

# Para emepzar a ejecutar servidor

# decorador
# cada vez que se entre a la parte principal de la app se hace la siguiente accion
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
    
    
    