#!/bin/bash
docker compose --compatibility restart
docker exec -it npre lnmp start
docker exec -it npre php /home/www/ruyi/server/server.php start -d
