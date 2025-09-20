#!/bin/bash

# CyberPanel + n8n Auto Installer Script
# Author: AI Assistant
# Version: 1.0
# Description: Automatically installs CyberPanel and n8n on Ubuntu VPS

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root. Use: sudo bash install.sh"
    fi
}

# Check Ubuntu version
check_ubuntu() {
    if ! grep -q "Ubuntu" /etc/os-release; then
        error "This script only supports Ubuntu"
    fi
    
    local version=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
    log "Detected Ubuntu $version"
    
    if [[ ! "$version" =~ ^(20\.04|22\.04|24\.04) ]]; then
        warning "Ubuntu version $version may not be fully supported. Recommended: 20.04, 22.04, or 24.04"
        read -p "Continue anyway? (y/n): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
}

# Check system requirements
check_requirements() {
    log "Checking system requirements..."
    
    # Check RAM
    local ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$ram_gb" -lt 2 ]; then
        warning "Recommended RAM: 2GB+. Current: ${ram_gb}GB"
        read -p "Continue with low RAM? (y/n): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
    
    # Check disk space
    local disk_gb=$(df / | awk 'NR==2{print int($4/1048576)}')
    if [ "$disk_gb" -lt 10 ]; then
        error "Minimum disk space required: 10GB. Available: ${disk_gb}GB"
    fi
    
    log "✅ System requirements check passed"
}

# Get user input
get_user_input() {
    echo -e "${BLUE}"
    echo "================================================="
    echo "  CyberPanel + n8n Auto Installer"
    echo "================================================="
    echo -e "${NC}"
    
    # Get n8n domain
    while true; do
        read -p "Enter domain/subdomain for n8n (e.g., n8n.yourdomain.com): " N8N_DOMAIN
        if [[ $N8N_DOMAIN =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]] || [[ $N8N_DOMAIN =~ ^[a-zA-Z0-9-]+\.[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
            break
        else
            echo "Invalid domain format. Please try again."
        fi
    done
    
    # Get n8n admin password
    while true; do
        read -s -p "Enter n8n admin password (min 8 characters): " N8N_PASSWORD
        echo
        if [ ${#N8N_PASSWORD} -ge 8 ]; then
            read -s -p "Confirm password: " N8N_PASSWORD_CONFIRM
            echo
            if [ "$N8N_PASSWORD" = "$N8N_PASSWORD_CONFIRM" ]; then
                break
            else
                echo "Passwords don't match. Please try again."
            fi
        else
            echo "Password must be at least 8 characters long."
        fi
    done
    
    # Optional: CyberPanel hostname
    read -p "Enter CyberPanel hostname (optional, e.g., panel.yourdomain.com): " CYBERPANEL_HOSTNAME
    
    # Skip firewall option
    read -p "Configure firewall? (y/n, default: n): " SETUP_FIREWALL
    SETUP_FIREWALL=${SETUP_FIREWALL:-n}
    
    echo
    echo "Configuration Summary:"
    echo "- n8n Domain: $N8N_DOMAIN"
    echo "- CyberPanel Hostname: ${CYBERPANEL_HOSTNAME:-"Not set (use IP:8090)"}"
    echo "- Setup Firewall: $SETUP_FIREWALL"
    echo
    read -p "Proceed with installation? (y/n): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
}

# Update system
update_system() {
    log "Updating system packages..."
    apt update -y
    apt upgrade -y
    apt install -y curl wget software-properties-common apt-transport-https ca-certificates
}

# Install CyberPanel
install_cyberpanel() {
    log "Installing CyberPanel..."
    
    # Download and run CyberPanel installer
    curl -fsSL https://cyberpanel.net/install.sh -o cyberpanel_install.sh
    
    # Create expect script for automated installation
    cat > cyberpanel_expect.exp << 'EOF'
#!/usr/bin/expect -f
set timeout 300
spawn bash cyberpanel_install.sh

# Install CyberPanel
expect "Please choose to install" { send "1\r" }

# Choose OpenLiteSpeed
expect "Choose LiteSpeed version" { send "1\r" }

# Full installation
expect "Do you want to install full service" { send "Y\r" }

# Local MySQL
expect "Remote MySQL" { send "N\r" }

# Latest version
expect "CyberPanel Version" { send "\r" }

# Generate random password
expect "Please choose a password" { send "r\r" }

# Memcached
expect "Memcached" { send "Y\r" }

# Redis
expect "Redis" { send "Y\r" }

# Watchdog
expect "Watchdog" { send "Y\r" }

expect eof
EOF
    
    chmod +x cyberpanel_expect.exp
    
    # Install expect if not present
    apt install -y expect
    
    # Run automated installation
    ./cyberpanel_expect.exp
    
    # Clean up
    rm -f cyberpanel_install.sh cyberpanel_expect.exp
    
    log "✅ CyberPanel installation completed"
}

# Install Node.js
install_nodejs() {
    log "Installing Node.js LTS..."
    
    # Install Node.js LTS (v20.x)
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs
    
    # Verify installation
    local node_version=$(node --version)
    local npm_version=$(npm --version)
    log "✅ Node.js $node_version and npm $npm_version installed"
    
    # Check version compatibility
    local node_major=$(echo $node_version | cut -d'.' -f1 | sed 's/v//')
    if [ "$node_major" -lt 20 ]; then
        warning "Node.js version may be incompatible with latest n8n. Recommended: v20+"
    fi
}

# Install n8n
install_n8n() {
    log "Installing n8n..."
    
    # Install n8n globally
    npm install -g n8n
    
    # Create n8n directory
    mkdir -p /opt/n8n
    chown $SUDO_USER:$SUDO_USER /opt/n8n 2>/dev/null || chown nobody:nogroup /opt/n8n
    
    # Create environment file
    cat > /opt/n8n/.env << EOF
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=http
WEBHOOK_URL=http://${N8N_DOMAIN}:5678/
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD}
NODE_ENV=production
GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
N8N_SECURE_COOKIE=false
N8N_PUSH_BACKEND=polling
EOF
    
    log "✅ n8n installed and configured"
}

# Create n8n systemd service
create_n8n_service() {
    log "Creating n8n systemd service..."
    
    # Find correct paths
    local node_path=$(which node)
    local n8n_path=$(which n8n)
    
    # Create symbolic links for systemd
    ln -sf "$node_path" /usr/bin/node 2>/dev/null || true
    ln -sf "$n8n_path" /usr/bin/n8n 2>/dev/null || true
    
    # Create systemd service
    cat > /etc/systemd/system/n8n.service << EOF
[Unit]
Description=n8n workflow automation
Documentation=https://n8n.io
After=network.target

[Service]
Type=simple
User=root
EnvironmentFile=/opt/n8n/.env
ExecStart=$node_path $n8n_path start
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
    
    # Enable and start service
    systemctl daemon-reload
    systemctl enable n8n
    systemctl start n8n
    
    # Check service status
    sleep 5
    if systemctl is-active --quiet n8n; then
        log "✅ n8n service started successfully"
    else
        warning "n8n service may have issues. Check with: journalctl -u n8n -f"
    fi
}

# Setup firewall
setup_firewall() {
    if [[ $SETUP_FIREWALL =~ ^[Yy]$ ]]; then
        log "Setting up firewall..."
        
        # Install UFW if not present
        apt install -y ufw
        
        # Reset firewall
        ufw --force reset
        
        # Configure rules
        ufw allow 22/tcp      # SSH
        ufw allow 8090/tcp    # CyberPanel
        ufw allow 80/tcp      # HTTP
        ufw allow 443/tcp     # HTTPS
        ufw allow 5678/tcp    # n8n
        
        # Enable firewall
        ufw --force enable
        
        log "✅ Firewall configured"
        ufw status
    else
        log "⏭️  Skipping firewall setup"
    fi
}

# Setup CyberPanel hostname (if provided)
setup_cyberpanel_hostname() {
    if [ -n "$CYBERPANEL_HOSTNAME" ]; then
        log "Note: To complete CyberPanel hostname setup:"
        echo "1. Ensure DNS record for $CYBERPANEL_HOSTNAME points to this server"
        echo "2. Access CyberPanel at https://$(curl -s ifconfig.me):8090"
        echo "3. Use Setup Wizard to configure hostname: $CYBERPANEL_HOSTNAME"
    fi
}

# Display final information
display_final_info() {
    local server_ip=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")
    
    echo
    echo -e "${GREEN}================================================="
    echo "  Installation Completed Successfully! 🎉"
    echo "=================================================${NC}"
    echo
    echo -e "${BLUE}📋 Access Information:${NC}"
    echo "┌─────────────────────────────────────────────────"
    echo "│ 🌐 CyberPanel:"
    echo "│    URL: https://$server_ip:8090"
    if [ -n "$CYBERPANEL_HOSTNAME" ]; then
        echo "│    Custom: https://$CYBERPANEL_HOSTNAME:8090 (after DNS setup)"
    fi
    echo "│    Default login: admin / [check installation output]"
    echo "│"
    echo "│ 🔧 n8n Automation:"
    echo "│    URL: http://$N8N_DOMAIN:5678"
    echo "│    Username: admin"
    echo "│    Password: [hidden]"
    echo "│"
    echo "│ 📊 Service Status:"
    echo "│    CyberPanel: $(systemctl is-active cyberpanel 2>/dev/null || echo "Check manually")"
    echo "│    n8n: $(systemctl is-active n8n)"
    echo "│    OpenLiteSpeed: $(systemctl is-active lshttpd 2>/dev/null || echo "Check manually")"
    echo "└─────────────────────────────────────────────────"
    echo
    echo -e "${YELLOW}⚠️  Important Notes:${NC}"
    echo "• Ensure DNS records point to this server IP: $server_ip"
    echo "• n8n domain: $N8N_DOMAIN → $server_ip"
    if [ -n "$CYBERPANEL_HOSTNAME" ]; then
        echo "• CyberPanel hostname: $CYBERPANEL_HOSTNAME → $server_ip"
    fi
    echo "• Use CyberPanel Setup Wizard for hostname configuration"
    echo "• n8n is configured with polling mode (compatible with OpenLiteSpeed)"
    echo
    echo -e "${BLUE}🔧 Useful Commands:${NC}"
    echo "• Check n8n status: systemctl status n8n"
    echo "• View n8n logs: journalctl -u n8n -f"
    echo "• Restart n8n: systemctl restart n8n"
    echo "• CyberPanel logs: tail -f /usr/local/CyberCP/logs/access.log"
    echo
    echo -e "${GREEN}🚀 Next Steps:${NC}"
    echo "1. Configure DNS records as shown above"
    echo "2. Access CyberPanel and complete Setup Wizard"
    echo "3. Access n8n and start creating workflows"
    echo "4. Create your first website in CyberPanel"
    echo
    echo "Installation log saved to: /var/log/cyberpanel-n8n-install.log"
    echo
}

# Main installation function
main() {
    # Redirect output to log file
    exec > >(tee -a /var/log/cyberpanel-n8n-install.log)
    exec 2>&1
    
    log "Starting CyberPanel + n8n installation..."
    
    check_root
    check_ubuntu
    check_requirements
    get_user_input
    
    log "Starting installation process..."
    
    update_system
    install_cyberpanel
    install_nodejs
    install_n8n
    create_n8n_service
    setup_firewall
    setup_cyberpanel_hostname
    
    display_final_info
    
    log "Installation completed successfully! 🎉"
}

# Run main function
main "$@"
