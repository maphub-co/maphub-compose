### MapHub – Minimal setup (single section)

Follow these concise steps to get the production Compose stack online with HTTPS via Traefik and Let’s Encrypt:


1) Server prerequisites
- Docker Engine and Docker Compose plugin installed
- Ports `80` and `443` open to the internet
- Traefik needs the container socket; default is `CONTAINER_SOCK=/var/run/docker.sock` (change only if your socket path differs)


2) DNS → Point three records to your server’s public IP
- `FRONT_DOMAIN` (e.g., `maphub.example.com`)
- `API_DOMAIN` (e.g., `maphub-api.example.com`)
- `AUTH_DOMAIN` (e.g., `maphub-auth.example.com`)

3) Configure env and start
```bash
cd maphub-compose
cp .env.example .env
# Edit .env and minimally set:
# FRONT_DOMAIN, API_DOMAIN, AUTH_DOMAIN
# LETSENCRYPT_EMAIL (for certificate issuance)
# MAPBOX_TOKEN (frontend maps)
# Optionally: FRONT_AUTH_SECRET (random 32+ chars)
# Ensure CONTAINER_SOCK is correct for your engine
make up
```

4) Verify
- Frontend: `https://$FRONT_DOMAIN`
- API: `https://$API_DOMAIN`
- Keycloak: `https://$AUTH_DOMAIN`

Notes
- First TLS issuance can take a couple of minutes.
- If things don’t come up, run `make logs` and ensure DNS and ports `80/443` are reachable.

---

### Environment variables reference

| Variable | Required | Default | Description |
|---|---|---|---|
| `FRONT_DOMAIN` | Yes | — | Public domain for the frontend; Traefik routes and Next.js base URL use this. |
| `API_DOMAIN` | Yes | — | Public domain for the API. |
| `AUTH_DOMAIN` | Yes | — | Public domain for Keycloak. |
| `CONTAINER_SOCK` | Yes | `/var/run/docker.sock` | Path to container engine socket mounted into Traefik. |
| `LETSENCRYPT_EMAIL` | Yes | — | Email for Let’s Encrypt issuance/expiry notices. |
| `FRONT_AUTH_SECRET` | Recommended | — | Secret for NextAuth; use a cryptographically random 32+ char string. |
| `MAPBOX_TOKEN` | Yes | — | Public Mapbox token for the frontend. |
| `POSTGRES_USER` | No | `postgres` | Postgres user. |
| `POSTGRES_PASSWORD` | No | `admin` | Postgres password. Change in production. |
| `POSTGRES_DB` | No | `maphub` | Postgres database name. |
| `MINIO_ROOT_USER` | No | `minioadmin` | MinIO root access key. Change in production. |
| `MINIO_ROOT_PASSWORD` | No | `minioadmin` | MinIO root secret key. Change in production. |
| `MINIO_SECURE` | No | `false` | Whether API talks to MinIO via TLS (`true`/`false`). |
| `DATA_BUCKET` | No | `maphub-data` | MinIO bucket for app data. |
| `AUTH_PROVIDER` | No | `keycloak` | Authentication provider (stack is set up for Keycloak). |
| `KEYCLOAK_ADMIN` | No | `admin` | Keycloak admin username (container bootstrap). |
| `KEYCLOAK_ADMIN_PASSWORD` | No | `admin` | Keycloak admin password (container bootstrap). Change in production. |
| `KEYCLOAK_REALM` | No | `maphub` | Realm name used by frontend and API. |
| `KEYCLOAK_CLIENT_ID` | No | `maphub-frontend` | OIDC client ID used by the frontend in the realm. |
| `MAIL_USERNAME` | No | — | SMTP username for API emails (optional). Leave empty to disable. |
| `MAIL_PASSWORD` | No | — | SMTP password. |
| `MAIL_PORT` | No | `587` | SMTP port. |
| `MAIL_SERVER` | No | — | SMTP server host. |
| `MAIL_USE_TLS` | No | — | If SMTP requires STARTTLS (`true`/`false`). |
| `MAIL_USE_SSL` | No | — | If SMTP uses implicit SSL (`true`/`false`). |
| `MAIL_FROM` | No | `notifications@maphub.local` | Sender address for API emails. |
| `MAIL_FROM_NAME` | No | `MapHub Notifications` | Sender display name for API emails. |

---

### Container sources
- Traefik v2.11: https://hub.docker.com/_/traefik • Docs: https://doc.traefik.io/traefik/
- Postgres 16-alpine: https://hub.docker.com/_/postgres
- MinIO: https://hub.docker.com/r/minio/minio • Source: https://github.com/minio/minio
- Keycloak 25: https://quay.io/repository/keycloak/keycloak • Source: https://github.com/keycloak/keycloak
- MapHub API image (`noxdecima/maphub-api`): https://hub.docker.com/r/noxdecima/maphub-api
- MapHub Front image (`noxdecima/maphub-front`): https://hub.docker.com/r/noxdecima/maphub-front

---

### Troubleshooting (quick)
- No certs? Ensure DNS is correct, `LETSENCRYPT_EMAIL` is set, and ports `80/443` are open. Wait a few minutes.
- Routing issues? Confirm `CONTAINER_SOCK` path exists and `.env` domains match the Traefik labels.
- Auth/login issues? Verify `FRONT_DOMAIN`, `AUTH_DOMAIN`, `KEYCLOAK_REALM`, and `KEYCLOAK_CLIENT_ID` are consistent across `.env`, the generated realm, and Compose labels.