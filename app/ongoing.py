from flask import Flask, render_template, request
import requests
from selenium import webdriver

app = Flask(__name__,
            static_url_path='', 
            static_folder='assets')

def expand_url(url):
    try:
        url = requests.head(url, allow_redirects=True).url

        # Create a headless browser instance
        options = webdriver.ChromeOptions()
        options.add_argument('--headless')
        driver = webdriver.Chrome(options=options)

        # Navigate to the URL
        driver.get(url)

        # Take a screenshot of the page
        driver.save_screenshot('app/assets/screenshot.png')

        # Close the browser
        driver.quit()
    
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
    return render_template('index.html', url=url)

if __name__ == '__main__':
    app.run(debug=True)