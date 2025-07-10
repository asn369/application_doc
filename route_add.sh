#!/bin/bash

USER="root"
PASSWORD="root@321"
OUTPUT_DIR="machinename"

# Create output folder if not exists
mkdir -p "$OUTPUT_DIR"

# Create the script content once
SCRIPT_CONTENT=$(cat << 'EOF'
#!/bin/bash
ip route add 13.250.184.165/32 via 192.168.1.10
ip route add 13.251.25.238/32 via 192.168.1.10
ip route add 14.143.239.122/32 via 192.168.1.10
EOF
)

# Save script temporarily
echo "$SCRIPT_CONTENT" > /tmp/set_route.sh
chmod +x /tmp/set_route.sh

# Loop through IPs
for i in {15..254}; do
  IP="192.168.1.$i"
  echo "Checking $IP..."

  if ping -c 1 -W 1 "$IP" > /dev/null; then
    echo "Connecting to $IP..."

    # Copy and run script remotely
    sshpass -p "$PASSWORD" scp -o ConnectTimeout=3 -o StrictHostKeyChecking=no /tmp/set_route.sh ${USER}@${IP}:/tmp/set_route.sh
    if sshpass -p "$PASSWORD" ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no ${USER}@${IP} "chmod +x /tmp/set_route.sh && /tmp/set_route.sh"; then
      echo "$IP - Routes added successfully."
    else
      echo "$IP - SSH command failed or script error."
    fi
  else
    echo "$IP is unreachable, skipping."
  fi
done

