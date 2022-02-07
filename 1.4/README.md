


# Pre-requisites software

- If you alrady have vagarnt and oracle virtual box installed, then kindly uninstall first.
- Vagrant (1.9.3) : https://releases.hashicorp.com/vagrant/1.9.3/vagrant_1.9.3.msi
- Oracle Virtual Box (5.1.18) : http://download.virtualbox.org/virtualbox/5.1.18/VirtualBox-5.1.18-114002-Win.exe
- Git Bash : https://git-scm.com/download/win

# 0: Learn Fabric

- git clone https://github.com/dparmar1/learnfabric.git

# 1: Fabric Java SDK

- git clone  https://github.com/hyperledger/fabric-sdk-java.git
- cd fabric
- git checkout v1.0.1
- cd ..

# 2: Fabric

- git clone  https://github.com/hyperledger/fabric.git
- cd fabric
- git checkout v1.0.1
- copy "Vagrantfile" from "learnfabric" folder and overwrite in "devenv" folder of fabric. 
- cd ..

# 3: Initialize VM and Login into Ubuntu VM

- cd fabric/devenv
- vagrant up
- vagrant ssh
- make docker

# 4: Fabric CA

- cd ..
- git clone git clone  https://github.com/hyperledger/fabric-ca.git
- cd fabric-ca
- make docker

# 5: Download Fabric Samples

- git clone https://github.com/hyperledger/fabric-samples.git
- cd fabric-samples
- curl -sSL https://goo.gl/5ftp2f | bash

# 6: Create Basic Fabric Network

- cd fabric-samples
- cd basic-network
- ./generate.sh
- vi start.sh
- add keyword 'cli'
- Save start.sh file
- ./start.sh

# 7: Deploy and Test Chaincode (CLI)

- docker exec -it cli bash
- peer chaincode install -n mycc -v 1.0 -p github.com/chaincode_example02
- peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member')"
- peer chaincode invoke -C mychannel -n mycc -c '{"Args":["query","a"]}'
- peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'

# 8: Deploy and Test Chaincode (Using Fabric Java SDK)

- Go to VM
- cd /opt/gopath/src/github.com/hyperledger/fabric/sdkintegration
- docker-compose down;  rm -rf /var/hyperledger/*; docker-compose up --force-recreate -d
- Go to Host OS terminal and Keep your vagrant running
- cd fabric-sdk-java
- mvn eclipse:eclipse
- Open fabric-java-sdk as java project in eclipse
- Run End2endIT.java in eclipse

# 9: Deploy and Test Chaincode (Using Fabric Node SDK)

- git clone https://github.com/hyperledger/fabric-sdk-node.git
- cd fabric-sdk-node
- sudo apt-get update
- sudo npm install -g gulp
- sudo apt-get install build-essential curl git m4 ruby texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev
- sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
- export PATH="$HOME/.linuxbrew/bin:$PATH"
- rm -rf /tmp/hfc-*
- rm -rf ~/.hfc-key-store
- sudo npm install

