#!/bin/bash

# Exit if the number of nodes to add is not provided
if [ -z "$1" ]; then
  echo "Usage: ./scale_datanodes.sh <number_of_nodes_to_add>"
  exit 1
fi

# Find the highest existing s<number> container
# Extract numbers from names like s2, s3, sort them, and get the last one
LAST_INDEX=$(docker ps -a --format '{{.Names}}' | grep -E '^s[0-9]+$' | sed 's/s//' | sort -n | tail -n 1)

# If no such containers exist, start from s2
if [ -z "$LAST_INDEX" ]; then
  LAST_INDEX=1
fi

# Calculate where to start and end based on the number of nodes to add
START_INDEX=$((LAST_INDEX + 1))
END_INDEX=$((START_INDEX + $1 - 1))

# Image and network to use (update if yours are different)
IMAGE_NAME="hadoop_cluster-s1"
NETWORK_NAME="hadoop_cluster_hnet"

# Loop through each new node index
for i in $(seq $START_INDEX $END_INDEX); do
  # Create a named Docker volume for the DataNode
  docker volume create dn${i}

  # Run the DataNode container with custom name, hostname, and volume
  docker run -it -d \
    --name s${i} \
    --hostname s${i} \
    --network ${NETWORK_NAME} \
    -v dn${i}:/usr/local/hadoop/hdfs/datanode \
    ${IMAGE_NAME}
done
