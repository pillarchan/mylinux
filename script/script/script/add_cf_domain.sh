#!/bin/bash
for domain in $(cat domain.txt); do \
curl -X POST -H “X-Auth-Key: $CF_API_KEY” -H “X-Auth-Email: $CF_API_EMAIL” \

-H “Content-Type: application/json” \

“https://api.CloudFlare.com/client/v4/zones” \

–data ‘{“name”:”‘$domain'”,”jump_start”:true}’; 
done
