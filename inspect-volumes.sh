#!/usr/bin/env bash

# Print script header and usage information
echo "Docker Volume Inspector"
echo "======================="
echo "Identifies unnamed volumes and their container associations"
echo ""

# Function to get container mount path for a specific volume
get_mount_path() {
  local container_id=$1
  local vol_name=$2
  local vol_mountpoint=$3

  # Try different methods to match the volume
  docker inspect "$container_id" | jq -r --arg vol "$vol_name" --arg mp "$vol_mountpoint" '
    .[0].Mounts[] |
    select(
      (.Name == $vol) or
      (.Source | contains($vol)) or
      (.Source == $mp)
    ) |
    .Destination // "Mount path not found"
  '
}

# Function to get volume size
get_volume_size() {
  local mountpoint=$1
  if [ -d "$mountpoint" ]; then
    du -sh "$mountpoint" 2>/dev/null | cut -f1
  else
    echo "N/A"
  fi
}

# Function to check if a volume name appears to be a hash (not explicitly named)
is_hash_volume() {
  local vol_name=$1
  # Check if the volume name contains an underscore (typical for named volumes from compose)
  if [[ "$vol_name" == *"_"* ]]; then
    return 1  # Named volume (return false)
  fi

  # Check if volume name matches hash pattern (hexadecimal and long)
  if [[ "$vol_name" =~ ^[0-9a-f]{32,}$ ]]; then
    return 0  # Hash volume (return true)
  elif [[ "$vol_name" =~ ^[0-9a-f]{64}$ ]]; then
    return 0  # Hash volume (return true)
  else
    return 1  # Named volume (return false)
  fi
}

# Set counter for unnamed volumes
unnamed_count=0

# Loop through all volumes
for vol in $(docker volume ls -q); do
  # Check if this is a hash volume (unnamed)
  if is_hash_volume "$vol"; then
    # Increment counter
    ((unnamed_count++))

    echo "Volume: $vol"

    # Get volume mountpoint
    mountpoint=$(docker volume inspect "$vol" | jq -r '.[0].Mountpoint')
    echo "Mountpoint: $mountpoint"

    # Get volume size if possible
    size=$(get_volume_size "$mountpoint")
    echo "Size: $size"

    # Find containers using this volume
    container_info=$(docker ps -a --filter "volume=$vol" --format "{{.ID}} {{.Names}}")

    if [ -n "$container_info" ]; then
      echo "Used by containers:"
      while read -r container; do
        if [ -n "$container" ]; then
          container_id=$(echo "$container" | cut -d' ' -f1)
          container_name=$(echo "$container" | cut -d' ' -f2)

          # Get mount path inside container
          mount_path=$(get_mount_path "$container_id" "$vol" "$mountpoint")

          echo "  - $container_name ($container_id)"
          echo "    Mount path: $mount_path"
        fi
      done <<< "$container_info"
    else
      echo "Not used by any running container (orphaned)"
    fi
    echo "--------------------------------------"
  fi
done

# Show summary of results
if [ $unnamed_count -eq 0 ]; then
  echo "No unnamed volumes found. Good job!"
else
  echo "Found $unnamed_count unnamed volumes."
fi

# Add a helpful message about cleanup at the end
echo ""
echo "To remove orphaned volumes, run: docker volume prune"
echo "To remove a specific volume: docker volume rm <volume-name>"
echo ""
echo "To prevent random volume creation:"
echo "1. Use named volumes in docker-compose files"
echo "2. Use bind mounts when appropriate"
echo "3. Add the --rm flag for temporary containers"
