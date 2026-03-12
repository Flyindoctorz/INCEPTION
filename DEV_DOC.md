# DEV_DOC.md — Developer Documentation

## Prerequisites

Before setting up the project, make sure the following are installed:

- **Docker** — https://docs.docker.com/engine/install/
- **Docker Compose** v2+ — bundled with Docker Desktop or install separately
- **make** — standard build tool
- A machine running Linux (the project requires a VM at 42 due to `sudo` restrictions)

---

## Environment Setup from Scratch

### 1. Clone the repository
```bash
git clone <your-repo-url>
cd inception
```

### 2. Configure the `.env` file
Create a `.env` file at the project root:
```env
DOMAIN_NAME=login.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_TITLE=My Inception Site
WP_ADMIN_USER=admin
WP_ADMIN_EMAIL=admin@login.42.fr
```

### 3. Create the secrets
```bash
mkdir -p srcs/secrets/
echo "your_db_password"   > srcs/secrets/db_password
echo "your_root_password" > srcs/secrets/db_root_password
```
> These files are mounted read-only inside containers at `/run/secrets/`.
> Never commit them — add `srcs/secrets/` to your `.gitignore`.

### 4. Add the domain to /etc/hosts
```bash
echo "127.0.0.1   login.42.fr" | sudo tee -a /etc/hosts
```

### 5. Create the volume directories
```bash
mkdir -p /home/cgelgon/data/wordpress
mkdir -p /home/cgelgon/data/mariadb
```

---

## Build & Launch with Makefile

| Command | Effect |
|---------|--------|
| `make all` | Build images and start all containers |
| `make up` | Start containers (no rebuild) |
| `make down` | Stop containers (keep volumes & images) |
| `make clean` | Stop and remove containers + images |
| `make fclean` | Full clean — removes containers, images and volumes ⚠️ |
| `make re` | Full rebuild from scratch |
| `make logs` | Stream logs from all containers |

---

## Useful Docker Commands

### Container management
```bash
docker compose ps                  # status of all services
docker compose logs -f             # live logs (all services)
docker compose logs mariadb        # logs for a specific service
docker compose exec wordpress sh   # open a shell inside a container
docker compose exec mariadb bash   # open a shell in MariaDB
```

### Database access
```bash
docker compose exec mariadb mariadb -u root -p
```

### Rebuild a single service
```bash
docker compose up -d --build nginx
```

### Inspect the Docker network
```bash
docker network inspect inception_inception
```

### Inspect volumes
```bash
docker volume ls
docker volume inspect inception_wp-data
docker volume inspect inception_db-data
```

---

## Project Data — Storage & Persistence

All persistent data is stored in **named Docker volumes** mapped to the host filesystem:

| Volume name | Host path | Contains |
|-------------|-----------|----------|
| `wp-data` | `/home/cgelgon/data/wordpress` | WordPress files, themes, uploads |
| `db-data` | `/home/cgelgon/data/mysql` | MariaDB database files |

Data **persists across container restarts**. It is only deleted when running `make fclean`
or manually removing the volumes with `docker volume rm`.

### Container image architecture
All images are built from custom Dockerfiles based on **Debian** (penultimate stable release).
No pre-built application images from Docker Hub are used.

```
srcs/
└── requirements/
    ├── nginx/
    │   ├── Dockerfile
    │   └── conf/
    ├── wordpress/
    │   ├── Dockerfile
    │   └── conf/
    └── mariadb/
        ├── Dockerfile
        └── conf/
```
