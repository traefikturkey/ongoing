Run:
```
docker run --dns 1.1.1.1 -p 5000:5000 --rm ghcr.io/traefikturkey/ongoing:latest
```
Access http://localhost:5000

--dns will override any local dns incase you are using pihole
