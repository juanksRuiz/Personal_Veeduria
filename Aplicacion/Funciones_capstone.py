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

    message = MIMEMultipart("alternative")
    message["Subject"] = "Ingreso a la APP Epsilon"
    message["From"] = sender_email
    message["To"] = receiver_email

    # Create the plain-text and HTML version of your message
    HTML = """\
                <html>
                <body>
                    <p>Bienvenido a la app Epsilon. Su usuario y contraseña son:<br>
                    User: %s <br>
                    Password: %s <br>
                    <a href="http://www.realpython.com">Epsilon </a>
                    para cambiar la contraseña.
                    </p>
                </body>
                </html>
                """ % (username, codigo)

    # Turn these into plain/html MIMEText objects
    part2 = MIMEText(HTML, "html")
    # Add HTML/plain-text parts to MIMEMultipart message
    # The email client will try to render the last part first
    message.attach(part2)

    # Create secure connection with server and send email
    context = ssl.create_default_context()
    with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
        server.login(sender_email, password)
        server.sendmail(
            sender_email, receiver_email, message.as_string()
        )

# NECESITA DE FUNCION LOGGING
def render_main_windows(user_name):
    """
    Muestra las ventanas principales de los usuarios dependiendo de su rol en la
    base de datos
    PARAMETROS:
        user_name: nombre de usuario
    RETORNA:
        ventana principal de los usuarios dependiendo de su rol
    """
    logging(user_name, '1', 'INICIO')
    cur.execute("SELECT esAdmin,esProfesor FROM personas "
                "JOIN empleado ON personas.codigo = empleado.codigo WHERE usuario= %s;",
                (user_name,))
    aux = cur.fetchone()
    if (None is aux):
        return redirect(url_for('main_student'))
    else:
        aux = list(aux)
        is_admin, is_teacher = aux

        # Get user type to know what main_window to open
        if is_admin and is_teacher:
            return render_template('admin/admin_teacher.html', user_name=user_name)
        elif is_admin:
            return redirect(url_for('main_admin'))
        else:
            return redirect(url_for('main_teacher'))

def logging(usuario, nivel, action, sobre_que=None, sobre_quien=None, asignatura=None, grupo=None,
            cuando=None, notas_antes=None, notas_despues=None):
    """
    Registra las actividades realizadas por los usuarios en la base de datos
    junto con su datestamp correspondiente
    PARAMETROS:
        usuario: usuario registrado en la base de datos de la persona que realiza la accion.
        nivel: determina la gravedad de la acción sobre la aplicación. Va de 1 a 3.
        sobre_que: sobre que parte de la aplicación se realiza la acción.
        sobre_quien: a que usuario o asignatura está afectando la acción.
        asignatura: nombre de la asignatura que está involucrada
        grupo: grupo al que pertenece la asignatura involucrada
        cuando: sobre que periodo académico se está realizando la acción.
        notas_antes: notas que serán editadas
        notas_despues: nuevos valores de las notas que serán editadas.
    """
    date = str(utc_to_local(datetime.utcnow()).strftime('%Y-%m-%d %H:%M:%S.%f'))
    if action == "INICIO":
        text = "El usuario " + usuario + " ha iniciado sesion."
        # Insercion en login
    elif action == "SALIDA":
        text = "El usuario " + usuario + " ha cerrado sesion."
        # Insercion en login
    elif action == 'CONSULTA':
        text = ("El usuario " + usuario + " realizó una consulta en " + sobre_que
                + (" acerca de  " + sobre_quien if sobre_quien is not None else "")
                + (" para " + asignatura if asignatura is not None else ""
                + " grupo " + grupo if grupo is not None else "")
                + (" en el periodo " + cuando if cuando is not None else ""))
        # Insercion en login.
    elif action == 'EDICION':
        text = ("El usuario " + usuario + " realizó una edicion sobre " + sobre_que
                + (" a " + sobre_quien if sobre_quien is not None else "")
                + (" en " + asignatura if asignatura is not None else ""
                + " grupo " + grupo if grupo is not None else "")
                + ("en el periodo " + cuando if cuando is not None else "") + (
                    " se cambiaron "
                    + ("".join([str(n) + ',' if n is not None else "" for n in notas_antes]))
                    + " por las notas "
                    + ("".join([str(n)+',' if n is not None else "" for n in notas_despues]))
                    if (sobre_que == "NOTAS" or sobre_que == "PORCENTAJE") else ""))
    elif action == 'IMPORTAR':
        text = ("El usuario " + usuario + " importó un archivo sobre " + sobre_que + ", acerca de "
                + (sobre_quien if sobre_quien is not None else "")
                + (" grupo " + grupo if grupo is not None else "") + " para el periodo "
                + (cuando if cuando is not None else ""))
    elif action == 'EXPORTAR':
        text = ("El usuario " + usuario + " exportó un archivo sobre " + sobre_que + ", acerca de "
                + (sobre_quien if sobre_quien is not None else "")
                + ("en " + asignatura if asignatura is not None else ""
                + " grupo " + grupo if grupo is not None else "")
                + " para el periodo " + (cuando if cuando is not None else ""))
    elif action == 'ALERTA':
        text == ("El usuario " + usuario + "generó una alerta sobre " + sobre_que + " acerca de "
                 + sobre_quien
                 + (" en " + asignatura if asignatura is not None else ""
                 + " grupo " + grupo if grupo is not None else "")
                 + " para el periodo " + (cuando if cuando is not None else ""))
    else:
        text = "El usuario " + usuario + " hizo halgo"
    cur.execute("INSERT INTO logging VALUES(%s,%s,%s,%s,%s)", (usuario, nivel, action, date, text))


@app.route("/login", methods=['POST', 'GET'])
def login():
    """
    Realizar el inicio de sesión para los usuarios de la aplicación
    verificando que la contraseña ingresada es la correcta y
    revisando si el usuario inicia sesion por primera vez
    RETORNA:
        Cambio de contraseña o inicio de sesión dependiendo de
        si es la primera vez que el usuario inicia sesión
    """
    if request.method == 'POST':
        username_input = request.form['username']
        password_input = request.form['passwd']
        # Verify username is on the database
        user = load_user(username_input)
        if not user:
            flash('El usuario no se encuentra registrado o la contraseña es incorrecta', 'error')
            return render_template('login.html')
        cur.execute("SELECT contrasena = crypt(%s, contrasena) FROM personas WHERE usuario = %s;",
                    (password_input, username_input))
        passwd = str(cur.fetchone()[0])
        if passwd == 'False':
            flash('El usuario no se encuentra registrado o la contraseña es incorrecta', 'error')
            return render_template('login.html')
        flask_login.login_user(user)
        cur.execute("""SELECT estado_cuenta FROM  personas WHERE usuario = %s  """,
                    (username_input,))
        first_time = str(cur.fetchone()[0])
        if first_time == 'True':
            return render_template('/change_passwd.html')
        else:
            return render_main_windows(username_input)
    else:
        return render_template('login.html')


@app.route("/change_passwd", methods=['POST', 'GET'])
@flask_login.login_required
def change_passwd():
    """
    Realiza el cambio de contraseña de un usuario actualizando
    la contraseña en la base de datos
    RETORNA:
        Ventana principal para el usuario si el cambio de contraseña
        fue exitoso
    """
    user_name = flask_login.current_user.id
    logging(user_name, '2', 'EDICION', sobre_que='CONTRASENA')
    password_input = request.form['passwd']
    password_input_conf = request.form['passwd_conf']
    if password_input != password_input_conf:
        flash('Las contraseña no coinciden', 'error')
        return render_template('change_passwd.html')
    else:
        cur.execute("""UPDATE personas set contrasena = crypt(%s,gen_salt('xdes'))
                    where usuario = %s; """, (password_input_conf, user_name))
        cur.execute("""UPDATE personas set estado_cuenta = '0' WHERE usuario = %s""", (user_name,))
        return render_main_windows(user_name)


@app.route("/forget_passwd", methods=['POST', 'GET'])
def forget_passwd():
    """
    Muestra el formulario de olvidó de los usuarios
    RETORNA:
        Formulario de olvidó la contraseña
    """
    return render_template('/forget_passwd.html')


@app.route("/send_forget_passwd", methods=['POST', 'GET'])
def send_forget_passwd():
    """
    Pide el correo al usuario que olvida su contraseña para
    enviar un correo con una contraseña temporal
    RETORNA:
        Formulario de login
    """
    user = request.form['username']
    cur.execute("""SELECT correo_institucional FROM personas
                WHERE usuario = %s """, (user,))
    email = cur.fetchone()[0]
    passwd = generate_passwd()
    cur.execute("""UPDATE personas set contrasena = crypt(%s,gen_salt('xdes'))
                    where usuario = %s; """, (passwd, user))
    cur.execute("""UPDATE personas set estado_cuenta = '1' WHERE usuario = %s""", (user,))
    send_email(user, email, passwd)
    return render_template('/login.html')


@app.route("/logout")
@flask_login.login_required
def logout():
    """
    Cierra la sesión de un usuario determinado
    RETORNA:
        Inicio de sesión
    """
    user_name = flask_login.current_user.id
    logging(user_name, '1', 'SALIR')
    flask_login.logout_user()
    return redirect(url_for('login'))
#==============================================================================
#==============================================================================


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
    
    
    