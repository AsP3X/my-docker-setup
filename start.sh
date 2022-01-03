#!/bin/bash

docker run -d --name apache2-container -e TZ=UTC -p 8080:80 ubuntu/apache2:2.4-21.10_beta