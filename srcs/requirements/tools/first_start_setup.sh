#!/bin/sh
set -e

# Read domain from .env file
DOMAIN=$(grep DOMAIN_NAME srcs/.env | cut -d '=' -f2)

echo "Setting up Inception for $DOMAIN"

# Add domain to hosts
if ! grep -q "$DOMAIN" /etc/hosts; then
    echo "127.0.0.1    $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
    echo "✓ Added domain to /etc/hosts"
fi

# Generate secrets
mkdir -p secrets
openssl rand -base64 32 > secrets/db_password.txt
openssl rand -base64 32 > secrets/db_root_password.txt
curl -s https://api.wordpress.org/secret-key/1.1/salt/ > secrets/credentials.txt
echo "✓ Generated secrets"

# Create data directories
mkdir -p "$HOME/data/mariadb" "$HOME/data/wordpress"
chmod -R 755 "$HOME/data" 2>/dev/null || sudo chmod -R 755 "$HOME/data"
echo "✓ Created data directories"

echo "Setup complete."
echo "Run: make build && make up"