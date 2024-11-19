#!/bin/bash

# Check if the directory and command are provided as arguments
if [ $# -lt 2 ]; then
  echo "Usage: $0 <directory> <command>"
  exit 1
fi

# Assign the first argument to directory and the rest to the command
DIR=$1
shift
COMMAND="$@"

# Navigate to each first-level subdirectory and run the command
find "$DIR" -mindepth 1 -maxdepth 1 -type d | while read SUBDIR; do
  echo "Navigating to: $SUBDIR"
  cd "$SUBDIR" || continue
  echo "Running command: $COMMAND"
  $COMMAND
done

# scp -r zaza@192.168.0.110:~/docker zaza@192.168.0.32:~/docker