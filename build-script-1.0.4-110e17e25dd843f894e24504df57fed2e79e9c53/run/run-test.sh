#!/usr/bin/bash

set -ex
#Override this command to do something fance for your project
#If this file doesn't exist, the defaul command, shown below, is executed.
docker-compose -f 'docker-compose.yml' up