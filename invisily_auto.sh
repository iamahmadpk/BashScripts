#!/bin/bash

# Function to copy SSH public key to a remote server
copy_ssh_key() {
    local user="$1"
    local ip="$2"

    # Get the SSH public key from the current server
    ssh_pub_key=$(cat ~/.ssh/id_rsa.pub)

    # Copy the SSH public key to the remote server
    ssh "$user@$ip" "mkdir -p ~/.ssh && echo '$ssh_pub_key' >> ~/.ssh/authorized_keys"
    
    if [ $? -eq 0 ]; then
        echo "SSH public key successfully copied to $user@$ip"
    else
        echo "Failed to copy SSH public key to $user@$ip"
    fi
}

# Check if the SSH key exists
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "SSH key not found. Please generate an SSH key using 'ssh-keygen' command."
    exit 1
fi

# Prompt the user for target servers and copy SSH key
while true; do
    read -p "Enter the username for the remote server (or 'exit' to quit): " username
    if [ "$username" = "exit" ]; then
        break
    fi

    read -p "Enter the IP address of the remote server: " ip_address

    # Copy the SSH public key to the specified server
    copy_ssh_key "$username" "$ip_address"
done


read -p "Enter the URL of the repository: " repo_url
read -p "Enter the username for the repository: " repo_username
read -s -p "Enter the password for the repository: " repo_password
echo

# Download the repository using wget with provided credentials
wget --user="$repo_username" --password="$repo_password" "$repo_url"

# Get the filename of the downloaded repository
repo_file=$(basename "$repo_url")

# Unzip the downloaded repository
unzip "$repo_file"

# Change directory to the extracted repository
#cd "${repo_file%.*}"
change_directory() {
    local matching_dir=$(find . -type d -name 'invisily*' -print -quit)
    if [ -n "$matching_dir" ]; then
        cd "$matching_dir" || exit 1
    else
        echo "Directory matching pattern 'invisily*' not found."
        exit 1
    fi
}

execute_install_script() {
    local db_ip="$1"
    local content_portal_ip="$2"

    sudo ./Install-invisily.sh \
        --installation-type=online \
        --install-all \
        --remote-db-ip="$db_ip" \
        --remote-db-ssh-port=22 \
        --remote-db-ssh-username=invisily \
        --remote-ssh-key=/home/invisily/.ssh/id_rsa \
        --db-root-password=Invisily123! \
        --portal-hostname=ap.invisily.org \
        --content-portal-hostname=cp.invisily.org \
        --content-portal-ip="$content_portal_ip" \
        --content-portal-ssh-username=invisily \
        --verbose
}

# Prompt the user for the database and content portal IPs
read -p "Enter the IP address for the database portal: " db_ip
read -p "Enter the IP address for the content portal: " content_portal_ip
change_directory
# Execute the Install-invisily.sh script with user-provided IPs
execute_install_script "$db_ip" "$content_portal_ip"
