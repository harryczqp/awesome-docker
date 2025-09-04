#!/bin/bash

set -e

# --- Functions ---

install_rclone() {
    echo "Downloading and running the official rclone install script..."
    if curl https://rclone.org/install.sh | sudo bash; then
        echo "rclone installation completed successfully."

        # Create config directory for the current user
        echo "Creating configuration directory at ~/.config/rclone..."
        mkdir -p "$HOME/.config/rclone"

        echo ""
        echo "--- Next Steps: Configuration ---"
        echo "The configuration directory has been created for you."
        echo "Before you can use rclone, you need to configure a remote."
        echo ""
        echo "1. Run 'rclone config' to start an interactive setup process."
        echo ""
        echo "2. If you have an existing 'rclone.conf' file, place it at:"
        echo "   $HOME/.config/rclone/rclone.conf"
        echo "---------------------------------"
    else
        echo "rclone installation failed."
        exit 1
    fi
}

uninstall_rclone() {
    echo "This will attempt to uninstall rclone."
    if ! command -v rclone &> /dev/null; then
        echo "rclone is not installed. Nothing to do."
        return
    fi

    RCLONE_PATH=$(command -v rclone)
    MAN_PATH="/usr/local/share/man/man1/rclone.1.gz"

    read -p "rclone binary is at $RCLONE_PATH. Are you sure you want to uninstall? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstallation cancelled."
        return
    fi

    echo "Removing rclone binary..."
    sudo rm "$RCLONE_PATH"

    if [ -f "$MAN_PATH" ]; then
        echo "Removing rclone man page..."
        sudo rm "$MAN_PATH"
    fi

    echo "rclone has been uninstalled."

    read -p "Do you also want to remove the rclone configuration directory (~/.config/rclone)? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -d "$HOME/.config/rclone" ]; then
            rm -ri "$HOME/.config/rclone"
            echo "Configuration directory removed."
        else
            echo "Configuration directory not found."
        fi
    fi
}

create_service() {
    echo "--- Systemd Service Creation for rclone mount ---"
    if ! command -v rclone &> /dev/null; then
        echo "rclone is not installed. Please install it first."
        return
    fi

    read -p "Enter the rclone remote and path (e.g., onedrive_backup_crypt:cszy): " RCLONE_REMOTE
    if [ -z "$RCLONE_REMOTE" ]; then
        echo "Remote cannot be empty. Aborting."
        return
    fi

    read -p "Enter the local mount point (e.g., /mnt/onedrive): " MOUNT_POINT
    if [ -z "$MOUNT_POINT" ]; then
        echo "Mount point cannot be empty. Aborting."
        return
    fi

    read -p "Enter the user to run the service as [$(whoami)]: " SERVICE_USER
    SERVICE_USER=${SERVICE_USER:-$(whoami)}

    USER_HOME=$(getent passwd "$SERVICE_USER" | cut -d: -f6)
    if [ -z "$USER_HOME" ]; then
        echo "Error: User '$SERVICE_USER' not found."
        return
    fi

    RCLONE_CONFIG_PATH="$USER_HOME/.config/rclone/rclone.conf"
    if [ ! -f "$RCLONE_CONFIG_PATH" ]; then
        echo "Warning: rclone config file not found at $RCLONE_CONFIG_PATH"
        read -p "A config file is required. Do you want to run 'rclone config' as user '$SERVICE_USER' now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo -u "$SERVICE_USER" rclone config
        else
            echo "Service creation cancelled. Please create a config file first."
            return
        fi
    fi

    if [ ! -d "$MOUNT_POINT" ]; then
        read -p "Mount point '$MOUNT_POINT' does not exist. Create it now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo mkdir -p "$MOUNT_POINT"
            sudo chown "$SERVICE_USER:$(id -gn "$SERVICE_USER")" "$MOUNT_POINT"
        else
            echo "Service creation cancelled."
            return
        fi
    fi

    local password_command_line=""
    read -p "Is your rclone configuration file encrypted with a password? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -sp "Enter the password for the config file: " RCLONE_CONFIG_PASS
        echo
        if [ -z "$RCLONE_CONFIG_PASS" ]; then
            echo "Password cannot be empty. Aborting."
            return
        fi

        local pass_script_dir="$USER_HOME/.config/rclone"
        sudo -u "$SERVICE_USER" mkdir -p "$pass_script_dir"
        local pass_script_path="$pass_script_dir/service_pass.sh"
        
        echo "Creating a password script at '$pass_script_path'…"
        printf '#!/bin/sh\necho "%s"' "$RCLONE_CONFIG_PASS" | sudo -u "$SERVICE_USER" tee "$pass_script_path" > /dev/null
        sudo -u "$SERVICE_USER" chmod 700 "$pass_script_path"

        password_command_line="--password-command '$pass_script_path'"
        echo "Password script created with restricted permissions."
    fi

    SERVICE_NAME="rclone-mount-$(systemd-escape --path "$MOUNT_POINT").service"
    SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"
    
    local full_exec_start="/usr/bin/rclone mount '$RCLONE_REMOTE' '$MOUNT_POINT' --config '$RCLONE_CONFIG_PATH' --allow-other --allow-non-empty --vfs-cache-mode full --log-level INFO $password_command_line"

    echo "The following service file will be created at $SERVICE_FILE:"
    echo "--------------------------------------------------"
    cat <<EOF
[Unit]
Description=rclone mount for $RCLONE_REMOTE
After=network-online.target

[Service]
Type=simple
User=$SERVICE_USER
Group=$(id -gn "$SERVICE_USER")
ExecStart=$full_exec_start
ExecStop=/bin/fusermount -u '$MOUNT_POINT'
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    echo "--------------------------------------------------"

    read -p "Proceed with creating the service file? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Service creation cancelled."
        return
    fi

    sudo bash -c "cat > '$SERVICE_FILE'" <<EOF
[Unit]
Description=rclone mount for $RCLONE_REMOTE
After=network-online.target

[Service]
Type=simple
User=$SERVICE_USER
Group=$(id -gn "$SERVICE_USER")
ExecStart=$full_exec_start
ExecStop=/bin/fusermount -u '$MOUNT_POINT'
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    echo "Service file created."
    read -p "Reload systemd, enable and start the service now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Reloading systemd daemon..."
        sudo systemctl daemon-reload
        echo "Enabling service $SERVICE_NAME..."
        sudo systemctl enable "$SERVICE_NAME"
        echo "Starting service $SERVICE_NAME..."
        sudo systemctl start "$SERVICE_NAME"
        echo "Service enabled and started. You can check its status with: sudo systemctl status $SERVICE_NAME"
        echo "To view logs, run: sudo journalctl -u $SERVICE_NAME -f"
    else
        echo "To enable and start the service later, run:"
        echo "sudo systemctl daemon-reload"
        echo "sudo systemctl enable $SERVICE_NAME"
        echo "sudo systemctl start $SERVICE_NAME"
    fi
}


view_logs() {
    echo "--- View rclone Service Logs ---"
    mapfile -t rclone_services < <(basename -a /etc/systemd/system/rclone-mount-*.service 2>/dev/null || true)

    if [ ${#rclone_services[@]} -eq 0 ]; then
        echo "No rclone mount services found."
        return
    fi

    PS3="Please select a service to view its logs (or 'Cancel'): "
    select service_name in "${rclone_services[@]}" "Cancel"; do
        if [ "$service_name" == "Cancel" ]; then
            echo "Operation cancelled."
            break
        fi
        if [ -n "$service_name" ]; then
            PS3="Select a log viewing option: "
            options=("View all logs" "Follow logs (-f)" "View last 100 lines" "Back")
            select opt in "${options[@]}"; do
                case $opt in
                    "View all logs") sudo journalctl -u "$service_name" --no-pager; break ;;
                    "Follow logs (-f)") sudo journalctl -u "$service_name" -f; break ;;
                    "View last 100 lines") sudo journalctl -u "$service_name" -n 100 --no-pager; break ;;
                    "Back") break ;;
                    *) echo "Invalid option $REPLY";;
                esac
            done
            break
        else
            echo "Invalid selection."
        fi
    done
}

delete_service() {
    echo "--- Delete rclone Systemd Service ---"
    mapfile -t rclone_services < <(basename -a /etc/systemd/system/rclone-mount-*.service 2>/dev/null || true)

    if [ ${#rclone_services[@]} -eq 0 ]; then
        echo "No rclone mount services found to delete."
        return
    fi

    PS3="Please select a service to delete (or 'Cancel'): "
    select service_name in "${rclone_services[@]}" "Cancel"; do
        if [ "$service_name" == "Cancel" ]; then
            echo "Operation cancelled."
            break
        fi
        if [ -n "$service_name" ]; then
            read -p "Are you sure you want to permanently delete the service '$service_name'? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Deletion cancelled."
                break
            fi

            echo "Stopping service $service_name..."
            sudo systemctl stop "$service_name" || true

            echo "Disabling service $service_name..."
            sudo systemctl disable "$service_name" || true

            SERVICE_FILE="/etc/systemd/system/$service_name"
            if [ -f "$SERVICE_FILE" ]; then
                PASS_SCRIPT_PATH=$(grep -oP '(?<=--password-command=")[^"]*' "$SERVICE_FILE" || true)
                if [ -n "$PASS_SCRIPT_PATH" ] && [ -f "$PASS_SCRIPT_PATH" ]; then
                    read -p "Found associated password script at '$PASS_SCRIPT_PATH'. Remove it? (y/n) " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        echo "Removing password script..."
                        sudo rm "$PASS_SCRIPT_PATH"
                    fi
                fi
                
                echo "Deleting service file $SERVICE_FILE..."
                sudo rm "$SERVICE_FILE"
            fi

            echo "Reloading systemd daemon..."
            sudo systemctl daemon-reload

            echo "Service '$service_name' has been deleted."
            break
        else
            echo "Invalid selection."
        fi
    done
}

# --- Main Menu ---

echo "rclone Interactive Manager"
echo "--------------------------"
PS3="Please select an option: "
options=(
    "Install/Update rclone"
    "Uninstall rclone"
    "Create systemd service for mount"
    "Delete systemd service"
    "View Service Logs"
    "Exit"
)
select opt in "${options[@]}"
do
    case $opt in
        "Install/Update rclone")
            install_rclone
            break
            ;;
        "Uninstall rclone")
            uninstall_rclone
            break
            ;;
        "Create systemd service for mount")
            create_service
            break
            ;;
        "Delete systemd service")
            delete_service
            break
            ;;
        "View Service Logs")
            view_logs
            break
            ;;
        "Exit")
            break
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done
