docker rm -f $(docker ps -aq)
docker volume prune
docker ps -a
docker volume ls
