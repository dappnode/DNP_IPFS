# Beware in the test docker-compose that travis 
# will do a docker-compose up in a the directory DNPIPFS
# Therefore the name of the network has to be dnpbind_network

docker-compose -f docker-compose-ipfs.yml up -d
docker-compose -f test/docker-compose-test.yml build
docker-compose -f test/docker-compose-test.yml run test