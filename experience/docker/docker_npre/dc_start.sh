#!/bin/bash
docker compose --compatibility up -d
docker exec -it npre lnmp start
docker exec -it npre php /home/www/ruyi/server/server.php start -d
