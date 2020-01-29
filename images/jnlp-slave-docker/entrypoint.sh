#!/bin/bash
sudo /etc/init.d/docker start
jenkins-agent "$@"
