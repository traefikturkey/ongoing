## OnGoing Summary

This project is a Flask web application that expands shortened URLs and takes screenshots of the resulting web pages using Selenium with a headless Chrome browser.

Main features:
- User submits a URL via a web form (served from `index.html`).
- Backend uses the `requests` library to follow redirects and expand the URL.
- Selenium loads the expanded URL in a headless browser and saves a screenshot to `app/static/screenshots/screenshot.png`.
- The result (expanded URL and screenshot) is rendered back to the user.
- Runs with Flask's built-in server (debug) or Hypercorn (production).
- Static assets (CSS, images, screenshots) are organized under `app/static/`.
- Includes Dockerfile, Makefile, and `requirements.txt` for containerization, automation, and dependencies.

Overall, it is a web tool for expanding shortened URLs and visually previewing their destination.




[![Build and Publish Docker Image](https://github.com/traefikturkey/ongoing/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/traefikturkey/ongoing/actions/workflows/docker-publish.yml)

![image](https://github.com/traefikturkey/ongoing/assets/219478/e720e08a-6980-4c59-846e-6631c9d50761)

### Docker
Run:
```bash
docker run --dns 1.1.1.1 -p 5000:5000 --rm ghcr.io/traefikturkey/ongoing:latest
```
Access http://localhost:5000

--dns will override any local dns incase you are using pihole


### Docker Compose

```docker-compose.yml
version: '3'

services:
  ongoing:
    image: ghcr.io/traefikturkey/ongoing:latest
    container_name: ongoing
    restart: unless-stopped
    ports:
      - 9380:9380
    volumes:
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ}
    dns:
      - 1.1.1.1
```
