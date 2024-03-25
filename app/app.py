import os
import requests
from datetime import datetime
from flask import Flask, render_template, request
from selenium import webdriver

app = Flask(__name__)

# Create a headless browser instance
options = webdriver.ChromeOptions()
options.add_argument('--headless')
driver = webdriver.Chrome(options=options)

def expand_url(url):
    try:
        url = requests.head(url, allow_redirects=True).url

        try:
            # Take a screenshot of the page
            driver.get(url)
            driver.save_screenshot('app/static/screenshots/screenshot.png')
        except Exception as e:
            return f"Error taking screenshot: {str(e)}"

        return url
    except Exception as e:
        return f"Error expanding URL: {str(e)}"

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        return expand_url(request.form.get('url'))
    if request.form.get('url'):
        url = expand_url(request.form.get('url'))
    else:
        url = 'https://shorturl.at/vSU17'
    return render_template('index.html', url=url, current_year=datetime.now().year)

if __name__ == '__main__':
  port = int(os.environ.get("ONGOING_PORT", 9380))
  print(f"Starting {os.environ.get('PROJECT_NAME').title()} server on port {port}")
  if os.environ.get("FLASK_DEBUG", "False") == "True":
    app.run(port=port, debug=True)
  else:
    from waitress import serve
    serve(app, host='0.0.0.0', port=port)