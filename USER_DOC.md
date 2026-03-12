# USER_DOC.md — User Documentation

## What is Inception?

Inception is a Docker-based web infrastructure that runs three services together:

| Service   | Role                                                         |
|-----------|--------------------------------------------------------------|
| **NGINX**     | Reverse proxy — sole entry point, handles HTTPS (TLSv1.3) |
| **WordPress** | Content management system (CMS) running with php-fpm        |
| **MariaDB**   | Relational database used by WordPress                        |

All services communicate through an isolated Docker network called `inception`.
Only NGINX is reachable from outside, on port **443**.

---

## Start & Stop the Project

### Start
```bash
make
```
This builds all Docker images and starts all containers.

### Stop (keep data)
```bash
make down
```
Stops all containers without deleting volumes or images.

### Full clean (removes everything)
```bash
make fclean
```
⚠️ This removes containers, images **and volumes** (all data will be lost).

---

## Access the Website

| URL | Description |
|-----|-------------|
| `https://login.42.fr:443` | Public website (WordPress frontend) |
| `https://login.42.fr:443/wp-login.php` | WordPress administration panel |

> Your browser may warn about a self-signed certificate — this is expected.
> Accept the security exception to proceed.

> Make sure `login.42.fr` resolves to `127.0.0.1` in your `/etc/hosts`:
> ```
> 127.0.0.1   login.42.fr
> ```

---

## Credentials & Secrets

Sensitive credentials are stored as **Docker Secrets** in `srcs/secrets/`.

| File | Contains |
|------|----------|
| `srcs/secrets/db_password` | WordPress database user password |
| `srcs/secrets/db_root_password` | MariaDB root password |

Non-sensitive configuration (domain name, database name, WP admin user) is in `.env` at the project root.

---

## Check That Services Are Running

```bash
docker compose ps
```
All three services (`nginx`, `wordpress`, `mariadb`) should show status **Up**.

```bash
docker compose logs -f
```
Stream live logs from all containers. Use `Ctrl+C` to stop.

```bash
docker compose logs nginx
docker compose logs wordpress
docker compose logs mariadb
```
View logs for a specific service.
