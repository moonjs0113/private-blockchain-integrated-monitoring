docker-compose -f docker-compose-mq.yaml up -d

sleep 10s

docker logs kafka0.example.com | grep started
docker logs kafka1.example.com | grep started
docker logs kafka2.example.com | grep started
docker logs kafka3.example.com | grep started
