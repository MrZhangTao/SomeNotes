import functools

from flask import (
    Blueprint, flash, g, redirect, render_template, request,
    session, url_for
)
from werkzeug.security import check_password_hash, generate_password_hash
from laoguan.db import get_db

# The authentication blueprint will have views to register new users and to log in
# and log out.
bp = Blueprint("auth", __name__, url_prefix="/auth")

@bp.route("/register", methods=("GET", "POST"))
def register():
    '''register account'''
    if request.method == "POST": #post data
        username = request.form["username"]
        password = request.form["password"]
        db = get_db()
        error = None #init error content
        if not username:
            error = "Username is required."
        elif not password:
            error = "Password is required."
        elif db.execute(
            "SELECT id FROM user WHERE username = ?", (username,)
        ).fetchone() is not None:
            error = "User {} is already registered.".format(username)
        if error is None:
            db.execute("INSERT INTO user (username, password) VALUES (?, ?)",
                (username, generate_password_hash(password))
            )
            db.commit()
            return redirect(url_for("auth.login"))

        flash(error)
    return render_template("auth/register.html")

@bp.route("/login", methods=("GET", "POST"))
def login():
    '''login account'''
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]
        db = get_db()
        error = None
        user = db.execute(
            "SELECT * FROM user WHERE username = ?", (username,)
        ).fetchone()
        if user is None:
            error = "Incorrect username"
        elif not check_password_hash(user["password"], password):
            error = "Incorrect password."

        if error is None:
            session.clear()
            session["user_id"] = user["id"]
            return redirect(url_for("index"))

        flash(error)
    return render_template("auth/login.html")

@bp.before_app_request
def load_logged_in_user():
    '''load logged user's data'''
    user_id = session.get("user_id")
    if user_id is None:
        g.user = None
    else:
        g.user = get_db().execute(
            "SELECT * FROM user WHERE id = ?", (user_id,)
        ).fetchone()

@bp.route("/logout")
def logout():
    '''logout account'''
    session.clear()
    return redirect(url_for("index"))
    
# require authentication in other views
def login_required(view):#view is a view function
    @functools.wraps(view)
    def wrapped_view(**kw):
        if g.user is None:
            return redirect(url_for("auth.login"))
        return view(**kw)
    return wrapped_view
