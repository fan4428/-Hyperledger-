//阿里云配置 docker 仓库加速地址 https://cr.console.aliyun.com/#/accelerator
1
sudo apt-get update -y && sudo apt-get upgrade -y

2
sudo adduser frog
sudo usermod -aG sudo frog
su - frog

3
curl -O https://hyperledger.github.io/composer/latest/prereqs-ubuntu.sh
chmod u+x prereqs-ubuntu.sh
如果执行下面报错需要先执行
(
sudo apt-get install software-properties-common -y
)
./prereqs-ubuntu.sh (因网络问题可能会执行错误多试几次)
//#可以替换 ./prereqs-ubuntu.sh 104 行 sudo curl -L "https://get.daocloud.io/docker/compose/releases/download/1.13.0/docker-compose-$(uname -s)-\$(uname -m)" \

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

(
也许执行下面不成功那就吧项目里的 t.sh 放到目录上执行 需要给权限
sudo chmod -R 777 t.sh
./t.sh
执行完后再把项目的两个压缩包传到 fabric-samples 上去 在执行命令
cd /home/frog/fabric-samples
tar -zxvf hyperledger-fabric-ca-linux-amd64-1.4.4.tar.gz
tar -zxvf hyperledger-fabric-linux-amd64-1.4.4.tar.gz
)

//curl -sSL http://bit.ly/2ysbOFE | bash -s
vim ~/.profile
在最后一行添加
export PATH=$PATH:$HOME/fabric-samples/bin
5
第一台机子
docker swarm init --advertise-addr 172.26.143.56 (node1 的 ip)
2,3 台机子
docker swarm join --token SWMTKN-1-1zpb17rqs56vyd31gej35v9nnr6sxrtew1uube3eablcmphk8j-955ys8d302g2pzg0tiy1pe1x1 172.26.143.56:2377

如果报错(This node is already part of a swarm. Use "docker swarm leave" to leave this swarm and join another one. )
执行 docker swarm leave --force

6
第一台机子
docker network create --attachable --driver overlay fabric

2,3 台机子
docker run -itd --name mybusybox --network fabric busybox

7 在第一台
git clone -b swarm https://github.com/eugeneyl/one-org-kafka.git
cd fabric-samples
export PATH=$PATH:$PWD/bin
//如果上边不行执行这个
//(
//vim ~/.profile
//在最后一行添加
//export PATH=$PATH:$HOME/fabric-samples/bin
//)

cd ~/one-org-kafka
sudo nano .env
填写 ip

//拷贝 hyperledger-fabric-ca-linux-amd64-1.4.4 hyperledger-fabric-linux-amd64-1.4.4 这两个文件到 fabric-samples 目录
//解压
//tar -zxvf hyperledger-fabric-ca-linux-amd64-1.4.4.tar.gz
//tar -zxvf hyperledger-fabric-linux-amd64-1.4.4.tar.gz
//cd /home/frog/fabric-samples/first-network
//./byfn.sh generate && ./byfn.sh up

cd ~/one-org-kafka
替换项目里的 generate 到目录
sudo chmod -R 777 generate.sh
sudo ./generate.sh

cd ~
sudo tar -czvf one-org-kafka.tar.gz one-org-kafka
把压缩包放到 node2 node3 上面
tar -xzvf one-org-kafka.tar.gz one-org-kafka
cd ~/one-org-kafka

//修改 node1.yaml 里面的 FABRIC_CA_SERVER_TLS_KEYFILE,FABRIC_CA_SERVER_CA_KEYFILE
//需要进入 docker hyperledger/fabric-ca 容器 docker exec -it cli /bin/bash
//替换成生成 ca 证书的路径
//(
// /etc/hyperledger/fabric-ca-server-config/b7426d0fe00bd7efed91498d1f9c7f772339c758793a4922fd4f994356d325a1_sk
//)

各自执行在各自 node 上
sudo docker-compose -f node1.yaml up -d
sudo docker-compose -f node2.yaml up -d
sudo docker-compose -f node3.yaml up -d
sudo docker-compose -f node4.yaml up -d

//sudo docker rm -f \$(sudo docker ps -aq) && sudo docker volume prune
如果报错误说是重名了
(
docker run -itd --name mybusybox --network fabric busybox

docker rm -f $(docker ps -aq)
  docker rmi  $(docker images -a | grep dev- | awk '{print \$3 }')
)

node1 上面

docker exec cli peer channel create -o orderer0.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

docker cp cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block .

//docker cp cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem .

在 node2 node3 上面
把 node1 one-org-kafka 下的 mychannel.block 拷贝下来放到 node2 3 上
cd ~/one-org-kafka
docker cp mychannel.block cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/

在 node1 2 3 上
docker exec cli peer channel join -b mychannel.block
docker exec cli peer chaincode install -n orders -v 1.0 -p github.com/chaincode/orders/
//如果安装 node chaincode
//docker exec cli peer chaincode install -n orders -v 1.0 -l node -p /opt/gopath/src/github.com/hyperledger/fabric/peer/scripts

在 node1
docker exec cli peer chaincode instantiate -o orderer0.example.com:7050 -C mychannel -l node -n orders -v 1.0 -c '{"Args":[]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

Step 15: Try out the chain code

docker exec cli peer chaincode invoke -o orderer0.example.com:7050 -C mychannel -n orders -c '{"Args":["initLedger"]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

docker exec cli peer chaincode query -C mychannel -n orders -c '{"Args":["queryAllOrders"]}'

docker exec cli peer chaincode invoke -o orderer0.example.com:7050 -C mychannel -n orders -c '{"Args":["createOrder","f", "23459348", "5493058", "Pending"]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

sudo docker exec cli peer chaincode query -C mychannel -n orders -c '{"Args":["queryOrder", "f"]}'

You now have a working fabric network that is set up across 3 nodes! You can follow the guide on https://medium.com/@eplt/5-minutes-to-install-hyperledger-explorer-with-fabric-on-ubuntu-18-04-digitalocean-9b100d0cfd7d to set up a hyperledger explorer to view the fabric.

Tearing down of the network
In order for you to tear down the entire hyperledger network, you can call the following command.

docker rm -f $(docker ps -aq) && docker rmi -f $(docker images | grep dev | awk '{print \$3}') && docker volume prune

https://github.com/guanpengchn/guanpengchn.github.io/issues/13

docker exec cli peer chaincode invoke -o orderer0.example.com:7050 -C mychannel -n orders -c '{"Args":["createOrder","a","b","10","a"]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

docker exec cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n orders --peerAddresses peer0.org1.example.com:7051 --peerAddresses peer0.org2.example.com:7051 -c '{"Args":["invoke","a","b","10"]}'

docker rm -f \$(docker ps -aq) && docker volume prune
sudo docker rm -f \$(sudo docker ps -aq) && sudo docker volume prune

    docker swarm join --token SWMTKN-1-20urw9l4oonitqsiqld0zujfuo48e1wynn22fykr817b16at90-cxrsgaz8wjlo5do28j8s2y9fm 39.99.190.29:2377
