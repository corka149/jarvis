from flask import Flask

from jarvis.views import home_view

app = Flask(__name__)
app.register_blueprint(home_view.blue_print)


def main():
    app.run(debug=True)


if __name__ == '__main__':
    main()
