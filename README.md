# Inception - Docker WordPress Stack

A containerized WordPress deployment using Docker Compose with NGINX, MariaDB, and PHP-FPM.  

## Architecture  

- **NGINX**: SSL-enabled reverse proxy (Alpine 3.20)  
- **WordPress**: PHP-FPM application server (Alpine 3.20)  
- **MariaDB**: Database server (Alpine 3.20)  
- **Security**: HTTPS-only, internal networking, Docker secrets  

## Quick Start  

1. **Create environment file**:  
   ```bash
   cp srcs/.env.example srcs/.env
   # Edit srcs/.env with your configuration
   ```

2. **Deploy**:  
   ```bash
   make all
   ```

## Environment Variables  

Create `srcs/.env` with:
```env
DOMAIN_NAME=your-domain.42.fr
WORDPRESS_DB_HOST=mariadb:3306
WORDPRESS_DB_NAME=wordpress_db
WORDPRESS_DB_TABLE_PREFIX=wp_
# ... (see .env.example for full list)
```

## Commands  

| Command | Description |
|---------|-------------|
| `make all` | Complete setup and deployment |
| `make up` | Start services |
| `make down` | Stop services |
| `make clean` | Remove unused Docker resources |
| `make fclean` | Full cleanup (removes data volumes) |

## Security Features  

- HTTPS-only (TLS 1.2/1.3)  
- Self-signed SSL certificates  
- Docker secrets for credentials  
- Internal container networking  
- No direct database access from host  

## Access  

After deployment, visit: `https://your-domain.42.fr`.  

**Note**: Add your domain to `/etc/hosts` or the setup script will do it automatically.   

________  
<div align="center">

<p><a href="https://www.hive.fi/en/curriculum">Hive (42 School Network)</a></p>  
<p>Developed by <a href="https://github.com/ipersids">Julia Persidskaia</a>.</p>

</div>
