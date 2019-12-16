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
cd ..
cd one-org-kafka
sudo nano .env

拷贝 hyperledger-fabric-ca-linux-amd64-1.4.4  hyperledger-fabric-linux-amd64-1.4.4 这两个文件到fabric-samples目录
解压
tar -zxvf hyperledger-fabric-ca-linux-amd64-1.4.4.tar.gz
tar -zxvf hyperledger-fabric-linux-amd64-1.4.4.tar.gz
cd /home/frog/fabric-samples/first-network
./byfn.sh generate && ./byfn.sh up

cd ~/one-org-kafka
sudo ./generate.sh







