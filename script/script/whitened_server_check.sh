#!/bin/bash
STATUS=$(systemctl status whitened_bot.service | grep "Active" | cut -d':' -f2 | cut -d' ' -f2)
[ $STATUS != 'active' ] && systemctl restart whitened_bot.service || echo -e "\e[32mthe service is running\e[0m";exit
