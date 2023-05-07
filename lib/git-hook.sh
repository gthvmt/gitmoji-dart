#!/bin/sh
# Gitmoji commit hook

# Parse the commit message from the message file by removing comments
message=$(grep -v '^#' "$1")

# Check if the commit message contains a separate title and message
if echo "$message" | grep -q -e '^$'; then
  # Separate the title and message
  title=$(echo "$message" | sed '/^$/q')
  message=$(echo "$message" | sed '1,/^$/d')
else
  # Use the entire message as the title
  title="$message"
  message=""
fi

# Run gitmoji
echo "$(
  exec < /dev/tty && dart run gitmoji commit -t "$title" -m "$message" 2>&1 >/dev/tty
)"
