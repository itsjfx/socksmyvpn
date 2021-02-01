# i'm not a bash god and not sure how to carry the env across any other way

echo "export SOCKS_LISTEN_IP=$SOCKS_LISTEN_IP" > /env_dump
echo "export SOCKS_PORT=$SOCKS_PORT" >> /env_dump
echo "export SOCKS_USER=$SOCKS_USER" >> /env_dump
echo "export SOCKS_PASSWORD=$SOCKS_PASSWORD" >> /env_dump
echo "export LOCAL_NETWORK=$LOCAL_NETWORK" >> /env_dump
echo "export DONT_KILL_SOCKS_SERVER_ON_DISCONNECT=$DONT_KILL_SOCKS_SERVER_ON_DISCONNECT" >> /env_dump
