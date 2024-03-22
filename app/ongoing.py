from flask import Flask, render_template, request
import requests

app = Flask(__name__,
            static_url_path='', 
            static_folder='assets')

def expand_url(url):
    try:
        return requests.head(url, allow_redirects=True).url
    except Exception as e:
        return f"Error expanding URL: {str(e)}"

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        return expand_url(request.form.get('url'))
    if request.form.get('url'):
        url = expand_url(request.form.get('url'))
    else:
        url = ''
    return render_template('index.html', url=url)

if __name__ == '__main__':
    app.run(debug=True)