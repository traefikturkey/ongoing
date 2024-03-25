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
