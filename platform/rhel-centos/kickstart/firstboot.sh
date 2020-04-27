#!/bin/bash

# Set GIT to your own git.
GIT="git@github.com:shippingport/ansible.git"
# Packages to install prior to running ansible-pull. Git and Ansible are required.
PACKAGES=("git" "ansible")
# Set MD5 to the RSA key fingerprint shared on GitHub's website:
# https://help.github.com/en/github/authenticating-to-github/testing-your-ssh-connection
# This way we can verify the key when adding SSH hosts later on.
MD5="16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48"

# Private key to your git repo
cat > /root/.ssh/id_rsa <<EOF
# Your private key here
EOF

# Add GitHub to known_hosts
# Import the keys to a temp file
ssh-keyscan -t rsa -H github.com >> /tmp/github_ssh
KEY=$(ssh-keygen -l -E md5 -f /tmp/github_ssh | awk '{print $2}' | cut -d":" -f 2- | awk '{print $1}')
if diff <(echo "$KEY") <(echo "$MD5"); then
    # Imported key matches with known-good key, so add the keys to known_hosts
    printf "SSH keys match!"
    cat /tmp/github_ssh >> /root/.ssh/known_hosts
    chmod 0600 /root/.ssh/id_rsa /root/.ssh/known_hosts
else
    # Imported key did not match, give user 30 seconds to import the keys anyway
    # This section is optional
    read -t 30 -p "SSH keys did not match. Import anyway? (NOT RECOMMENDED) [y/N]" -n 1 -r
    if [[ $REPLY =~ ^(y|Y)$ ]]; then
    # Import the key
        printf "\nAdding key anyway..."
        cat /tmp/github_ssh >> /root/.ssh/known_hosts
        chmod 0600 /root/.ssh/id_rsa /root/.ssh/known_hosts
        printf " Key added.\n"
    else
    # Exit script
    # Maybe do some rescue work here...
    printf "\nERROR: key mismatch! Aborting..."
    rm /root/.ssh/id_rsa
    printf "\nDeployment failed.\n"
    fi
    # Check if required packages are installed, and if not, install them
    for _package in "${PACKAGES[@]}"; do
        if ! rpm -q "$_package"; then
            yum install "$_package" -y
        fi
    done
    # Run Ansible!
    ansible-pull firstboot.yml -C master -U $GIT -f -i localhost, --full --purge
fi
