su - frog

cd ~/one-org-kafka

docker rm -f $(docker ps -aq) && docker rmi -f $(docker images | grep dev | awk '{print $3}') && docker volume prune
sudo docker rm -f $(sudo docker ps -aq) && sudo docker volume prune
Node 2
docker run -itd --name mybusybox --network fabric busybox

Node 1
sudo docker-compose -f node1.yaml up -d
Node 2
sudo docker-compose -f node2.yaml up -d
Node 1
sudo docker exec cli peer channel create -o orderer0.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
Node 1
sudo docker cp cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block .
Node 2
sudo docker cp mychannel.block cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/
Node 1 2
sudo docker exec cli peer channel join -b mychannel.block
Node 1 2
//docker exec -it cli /bin/bash
sudo docker exec cli peer chaincode install -n orders -v 1.0 -p github.com/chaincode/orders

sudo docker exec cli peer chaincode instantiate -o orderer0.example.com:7050 -C mychannel -n orders -v 1.0 -c '{"Args":[]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

sudo docker exec cli peer chaincode invoke -o orderer0.example.com:7050 -C mychannel -n orders -c '{"Args":["initLedger"]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

sudo docker exec cli peer chaincode invoke -o orderer0.example.com:7050 -C mychannel -n orders -c '{"Args":["createOrder","f", "23459348" ]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

docker exec cli peer chaincode invoke -o orderer0.example.com:7050 -C mychannel -n orders -c '{"Args":["fan","f", "23459348" ]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


//如果安装 node chaincode
{
docker exec cli peer chaincode install -n orders -v 1.0 -l node -p /opt/gopath/src/github.com/hyperledger/fabric/peer/scripts/
docker exec cli peer chaincode instantiate -o orderer0.example.com:7050 -C mychannel -l node  -n orders -v 1.0 -c '{"Args":[]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
}

sudo docker exec cli peer chaincode invoke -o orderer0.example.com:7050 -C mychannel -n orders -c '{"Args":["createOrder","fan", "22","33","44","55","66" ]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
sudo docker exec cli peer chaincode invoke -o orderer0.example.com:7050 -C mychannel -n orders -c '{"Args":["queryOrder","12" ]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
sudo docker exec cli peer chaincode invoke -o orderer0.example.com:7050 -C mychannel -n orders -c '{"Args":["queryAllOrders","1" ]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

sudo docker exec cli peer chaincode invoke -o orderer0.example.com:7050 -C mychannel -n orders -c '{"Args":["changeOrderStatus","1","2222" ]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

升级chaincode

sudo docker exec cli peer chaincode install -n orders -v 3.1 -p github.com/chaincode/magento_order/go

sudo docker exec cli peer chaincode upgrade -o orderer0.example.com:7050 -C mychannel -n orders -v 3.1 -c '{"Args":[""]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
sudo docker exec cli peer chaincode invoke -o orderer0.example.com:7050 -C mychannel -n orders -c '{"Args":["fan" ]}' --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


e78