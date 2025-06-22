# !/bin/bash

# export variables
# export REG_USER=username
# export REG_PASS=password

# Login to registry via crane
echo $REG_PASS | crane auth login 'docker.io' -u $REG_USER --password-stdin
# Copy images
crane copy ${1} ${2}
# Logout from registry
crane auth logout 'docker.io'