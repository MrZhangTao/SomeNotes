from flask import Flask
import os

def create_app(test_config=None):
    #create and configure the apps
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        SECRET_KEY="dev",
        DATABASE=os.path.join(app.instance_path, "laoguan.sqlite")
    )
    if test_config is None:
        #load the instance config, if it exists, when not testing
        app.config.from_pyfile("config.py", silent=True) #override
    else:
        #load the test config if passed in
        app.config.from_mapping(test_config) #write
    #ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    from . import db
    db.init_app(app)
    
    from . import auth
    app.register_blueprint(auth.bp)

    from . import blog
    app.register_blueprint(blog.bp)
    app.add_url_rule("/", endpoint="index") #路径又称"终点"（endpoint），表示API的具体网址

    # a simple page that says hello
    @app.route("/hello")
    def hello():
        return "Hello,老关！"
    
    return app

