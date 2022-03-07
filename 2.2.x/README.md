# Pre-requisites software (Locally if Windows OS-64bit)

If you alrady have vagarnt and oracle virtual box installed, then kindly uninstall first.

- Vagrant (2.2.19) : https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.msi
- Oracle Virtual Box (6.1.32) : https://download.virtualbox.org/virtualbox/6.1.32/VirtualBox-6.1.32-149290-Win.exe
- Git Bash : https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-64-bit.exe
- Python: https://www.python.org/ftp/python/3.9.10/python-3.9.10-embed-amd64.zip

# Pre-requisites software (Cloud if Ubuntu OS)

sudo apt-get update

sudo apt-get install ca-certificates curl gnupg lsb-release

sudo apt-get install build-essential

1) Git 

sudo apt-get install git

2) cURL

sudo apt-get install curl

3) Docker and Docker-compose

https://docs.docker.com/engine/install/ubuntu/

https://docs.docker.com/compose/install/

docker-compose --version

docker --version

Make sure the Docker daemon is running.
sudo systemctl start docker

Optional: If you want the Docker daemon to start when the system starts, use the following:
sudo systemctl enable docker

Add your user to the Docker group
sudo usermod -a -G docker <username>

4) Go

https://devmohit.medium.com/install-golang-setting-up-its-path-and-env-variable-cafae8c9f54

5) Jq

sudo apt-get install jq

6) NPM and NodeJS

sudo apt-get install build-essential
sudo apt-get remove nodejs
sudo apt-get remove npm
​
curl -sLhttps://deb.nodesource.com/setup_12.x| sudo -E bash -
​
sudo apt-get install -y nodejs    	

# Install fabric-samples

curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.0 1.4.9

# Genesis Process

1) Create crypto meterials (identities) for each organizations

cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output="organizations"

cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output="organizations"

cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"

2) Creating connection files for Org1 and Org2 (Not for orderer)

Refer ./organizations/ccp-generate.sh 

3) Create Genesis block 

configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block

4) Create Channel artifacts

configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME

Refer ./scripts/createChannel.sh

# Test-Network setup

1) ./network.sh up -ca

2) ./network.sh createChannel

OR

1) ./network.sh up createChannel -ca

3) Different Orgs join channel

# Commands : Chaincode lifecyle

1) Package

    peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CC_NAME}_${CC_VERSION} >&log.txt
	
	peer lifecycle chaincode package basic.tar.gz --path ../test-basic/chaincode-javascript/ --lang node --label basic_1.0

2) Install 

	peer lifecycle chaincode install ${CC_NAME}.tar.gz >&log.txt
	
	peer lifecycle chaincode install basic.tar.gz //Org1
	
	peer lifecycle chaincode install basic.tar.gz //Org2

3) QueryInstalled

	peer lifecycle chaincode queryinstalled >&log.txt
	
	peer lifecycle chaincode queryinstalled

4) ApproveForOrg

	peer lifecycle chaincode approveformyorg -o localhost:7050 \
	--ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA \
	--channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --package-id ${PACKAGE_ID} \
	--sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
	
	peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls \
	--cafile /home/deepak/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
	--channelID mychannel --name basic --version 1.0 --package-id basic_1.0:41c004d609e5a758b19049c060b8b70ea033466a0060c375e4320842fdf87f23 --sequence 1 // Org 1
	
	peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls \
	--cafile /home/deepak/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
	--channelID mychannel --name basic --version 1.0 --package-id basic_1.0:41c004d609e5a758b19049c060b8b70ea033466a0060c375e4320842fdf87f23 --sequence 1

5) Check Commit Readiness

	peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CC_NAME} \
	--version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} --output json >&log.txt
	
	peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --output json //Org1
	peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --output json //Org2
	

6) Commit

	peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA \
	--channelID $CHANNEL_NAME --name ${CC_NAME} $PEER_CONN_PARMS --version ${CC_VERSION} \
	--sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
	
	peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile /home/deepak/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacert
s/tlsca.example.com-cert.pem --channelID mychannel --name basic --peerAddresses localhost:7051 --tlsRootCertFiles /home/deepak/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --
peerAddresses localhost:9051 --tlsRootCertFiles /home/deepak/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --version 1.0 --sequence 1

7) QueryCommitted

	peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} >&log.txt
	
	peer lifecycle chaincode querycommitted --channelID mychannel --name basic //Org1
	peer lifecycle chaincode querycommitted --channelID mychannel --name basic //Org2
	
# Set Enviroment Variables

export PATH=${PWD}/../bin:$PATH

export FABRIC_CFG_PATH=$PWD/../config/

export CORE_PEER_TLS_ENABLED=true

1) Org 1
	
	export CORE_PEER_LOCALMSPID="Org1MSP"
	export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
	export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
	export CORE_PEER_ADDRESS=localhost:7051

2) Org 2

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

# Deploy Chaincode

./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-javascript/ -ccl javascript

# Commands : Chaincode Init/Invoke/Query

1) InvokeInit

	peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} $PEER_CONN_PARMS --isInit -c ${fcn_call} >&log.txt

2) Invoke

	peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} $PEER_CONN_PARMS --isInit -c ${fcn_call} >&log.txt

3) Query

	peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryAllCars"]}' >&log.txt


# State Database

docker exec -it <peer container id> sh

Core Dir Location@Peer: /var/hyperledger/production

1) Deploy Chaincode
./network.sh deployCC -ccn ledger -ccp ../asset-transfer-ledger-queries/chaincode-go/ -ccl go -ccep "OR('Org1MSP.peer','Org2MSP.peer')"

2) Invoke - CreateAsset function

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n ledger -c '{"Args":["CreateAsset","asset1","blue","5","tom","35"]}'

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n ledger -c '{"Args":["TransferAsset","asset1","deepak"]}'

3) Query - QueryAsset with Index

peer chaincode query -C mychannel -n ledger -c '{"Args":["QueryAssets", "{\"selector\":{\"docType\":\"asset\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}"]}'

docker ps --format "table {{.ID}}\t{{.Ports}}\t{{.Names}}"


# Add new Organization (Org3) into existing network

- Discuss about crypto-config
- Discuss about genesis block and channel artifacts
- Discuss about docker compose files
- Use addOrg3.sh script
- Anchor Peer and normal peer
- Private Data - https://hyperledger-fabric.readthedocs.io/en/release-2.2/private-data/private-data.html

# Attribute based access control
https://github.com/hyperledger/fabric-samples/tree/main/asset-transfer-abac

# Blockchain Explorer
Blockchain Explorer: https://github.com/hyperledger/blockchain-explorer

# Multi Contract and Cross Channel communications

Multiple Chaincode and Ledger: https://hyperledger-fabric.readthedocs.io/en/latest/peers/peers.html#multiple-chaincodes
System level chaincode - https://hyperledger-fabric.readthedocs.io/en/release/chaincode4noah.html
Inter channel Communication: https://hyperledger-fabric.readthedocs.io/en/release-1.4/smartcontract/smartcontract.html#intercommunication
Service Discovery: https://hyperledger-fabric.readthedocs.io/en/release-1.4/discovery-overview.html

1) One chaincode cannot directly read or update the state of another chaincode.
2) But one chaincode can call/invoke functions on a different chaincode.
3) If both chaincodes are on the same channel, then chaincode can call another chaincode to both read and write data.
4) If the two chaincodes are on different channels, then chaincode can only query a chaincode on a different channel.
5) The block generated by different chaincode(we can simplely think so) will be stored in the same one ledger
6) The field 'Chaincode Name' in block will distinguish it's generated from which chaincode













