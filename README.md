# -Hyperledger-

1 
sudo apt-get update && sudo apt-get upgrade

2 
sudo adduser frog
sudo usermod -aG sudo frog
su - frog

3
curl -O https://hyperledger.github.io/composer/latest/prereqs-ubuntu.sh
chmod u+x prereqs-ubuntu.sh
如果执行下面报错需要先执行 sudo apt-get install software-properties-common
./prereqs-ubuntu.sh

4

wget https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz
tar -xzvf go1.11.2.linux-amd64.tar.gz
sudo mv go/ /usr/local

nano ~/.bashrc
#(add these 2 lines to end of file)
export GOPATH=/usr/local/go
export PATH=$PATH:$GOPATH/bin

exit
su - frog

5
第一台机子
docker swarm init --advertise-addr 172.26.143.56
2,3台机子
docker swarm join --token SWMTKN-1-1zpb17rqs56vyd31gej35v9nnr6sxrtew1uube3eablcmphk8j-955ys8d302g2pzg0tiy1pe1x1 172.26.143.56:2377

如果报错(This node is already part of a swarm. Use "docker swarm leave" to leave this swarm and join another one. )
执行 docker swarm leave --force 

6
第一台机子
docker network create --attachable --driver overlay fabric
2,3台机子
docker run -itd --name mybusybox --network fabric busybox

7
git clone -b swarm https://github.com/eugeneyl/one-org-kafka.git
cd fabric-samples
export PATH=$PATH:$PWD/bin
如果上边不行执行这个
(
  vim ~/.profile
  # 在最后一行添加
  export PATH=$PATH:$HOME/fabric-samples/bin
)
cd ..
cd one-org-kafka
sudo nano .env

拷贝 hyperledger-fabric-ca-linux-amd64-1.4.4  hyperledger-fabric-linux-amd64-1.4.4 这两个文件到fabric-samples目录
解压
tar -zxvf hyperledger-fabric-ca-linux-amd64-1.4.4.tar.gz
tar -zxvf hyperledger-fabric-linux-amd64-1.4.4.tar.gz
cd /home/frog/fabric-samples/first-network
./byfn.sh generate && ./byfn.sh up

cd ~
tar -czvf one-org-kafka.tar.gz one-org-kafka
把压缩包放到node2 node3 上面
cd ~/one-org-kafka

修改node1.yaml里面的FABRIC_CA_SERVER_TLS_KEYFILE
替换成生成ca证书的路径
(
  /home/frog/one-org-kafka/crypto-config/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem
)
FABRIC_CA_SERVER_CA_KEYFILE
(
  /home/frog/one-org-kafka/crypto-config/peerOrganizations/org1.example.com/ca/c4e7edf932f810cbe20bd36242bbd7ec91e8b6e99ee7ca33a1739cf21f8668c5_sk
)

各自执行在各自node上
sudo docker-compose -f node1.yaml up -d
sudo docker-compose -f node2.yaml up -d
sudo docker-compose -f node3.yaml up -d
如果报错误说是重名了
(
  docker rm -f $(docker ps -aq)
  docker rmi  $(docker images -a | grep dev-  | awk '{print $3 }')
)
sudo ./generate.sh
docker exec cli peer channel create -o orderer0.frogfrogjump.com:7050 -c mychannel -f ./channel-artifacts/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/frogfrogjump.com/orderers/orderer0.frogfrogjump.com/msp/tlscacerts/tlsca.frogfrogjump.com-cert.pem
docker cp cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block .

在node2 node3 上面
把node1 one-org-kafka 下的 mychannel.block 拷贝下来放到node2 3 上
cd ~/one-org-kafka
docker cp mychannel.block cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/

在node1 2 3上
docker exec cli peer channel join -b mychannel.block







