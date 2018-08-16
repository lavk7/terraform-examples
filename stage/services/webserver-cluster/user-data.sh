#!/bin/bash
echo "${db_address}:${db_port}" > index.html
nohup busybox httpd -f -p "${server_port}" &