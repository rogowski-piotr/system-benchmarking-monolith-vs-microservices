from website import app
import website.config as config

app = app

if __name__ == '__main__':
    app.run(host=config.HOST, port=config.PORT)