#!/bin/bash

# Stop and remove docker-compose services
docker compose down -v

# Remove manually scaled s<number> containers
docker rm -f $(docker ps -aq --filter "name=^s[0-9]+$") 2>/dev/null

# Remove associated dn<number> volumes
for v in $(docker volume ls -q --filter name=^dn[0-9]+$); do
  docker volume rm "$v"
done