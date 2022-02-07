#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Build your first network (BYFN) end-to-end test"
echo
CHANNEL_NAME="$1"
CCNAME="$2"
INSTANTIATE="$3"
: ${CHANNEL_NAME:="mychannel"}
: ${TIMEOUT:="60"}
: ${CCNAME:="mufgslacc"}
: ${INSTANTIATE:="upgrade"}
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/sla.mufg.com/msp/tlscacerts/tlsca.sla.mufg.com-cert.pem
#CCNAME=citestcc
CCVERSION=`date +%Y-%m-%d-%H-%M-%S`
#ENDORSEMENT_POLICY="OR('MUFGSLApeerorg1.member','MUFGSLApeerorg2.member','MUFGSLApeerorg3.member','MUFGSLApeerorg4.member')"
ENDORSEMENT_POLICY="OR(AND('MUFGSLApeerorg1.member','MUFGSLApeerorg2.member','MUFGSLApeerorg3.member'),AND('MUFGSLApeerorg1.member','MUFGSLApeerorg2.member','MUFGSLApeerorg4.member'),AND('MUFGSLApeerorg1.member','MUFGSLApeerorg3.member','MUFGSLApeerorg4.member'),AND('MUFGSLApeerorg2.member','MUFGSLApeerorg3.member','MUFGSLApeerorg4.member'))"
#ENDORSEMENT_POLICY="OR('Org1MSP.member','Org2MSP.member')"
#INSTANTIATE="instantiate"

echo "Channel name : "$CHANNEL_NAME
echo "CCVERSION : "$CCVERSION
echo "CCNAME : "$CCNAME
echo "INSTANTIATE : "$INSTANTIATE

# verify the result of the end-to-end test
verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
		echo
   		exit 1
	fi
}

setGlobals () {

	ORGINDEX=$1
	# PORT=`expr "$1" "*" "1000" "+" "6051"`
	CORE_PEER_LOCALMSPID="MUFGSLApeerorg$ORGINDEX"
	CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$ORGINDEX.sla.mufg.com/peers/peer1.org$ORGINDEX.sla.mufg.com/tls/ca.crt
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$ORGINDEX.sla.mufg.com/users/Admin@org$ORGINDEX.sla.mufg.com/msp
	CORE_PEER_ADDRESS=peer1.org$ORGINDEX.sla.mufg.com:7051

	env |grep CORE
}

installChaincode () {
	PEER=$1
	setGlobals $PEER
	LOGFILENAME="installlog-$CCVERSION.txt"
	echo $LOGFILENAME
	echo peer chaincode install -n $CCNAME -v $CCVERSION -p mufg/sla/chaincode_main/ 
	peer chaincode install -n $CCNAME -v $CCVERSION -p mufg/sla/chaincode_main/ >& $LOGFILENAME
	res=$?
	cat $LOGFILENAME
        verifyResult $res "Chaincode installation on remote peer PEER$PEER has Failed"
	echo "===================== Chaincode is installed on remote peer PEER$PEER ===================== "
	echo
}

instantiateChaincode () {
	PEER=$1
	setGlobals $PEER
	LOGFILENAME=instantiate-$CCVERSION.txt
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode $INSTANTIATE -o orderer1.sla.mufg.com:7050 -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c '{"Args":["init","a","100","b","200"]}' -P "$ENDORSEMENT_POLICY" >&$LOGFILENAME
	else
		echo peer chaincode $INSTANTIATE -o orderer1.sla.mufg.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c '{"Args":[]}' -P "$ENDORSEMENT_POLICY"
		peer chaincode $INSTANTIATE -o orderer1.sla.mufg.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c '{"Args":[]}' -P "$ENDORSEMENT_POLICY" >&$LOGFILENAME
	fi
	res=$?
	cat $LOGFILENAME
	verifyResult $res "Chaincode instantiation on PEER$PEER on channel '$CHANNEL_NAME' failed"
	echo "===================== Chaincode Instantiation on PEER$PEER on channel '$CHANNEL_NAME' is successful ===================== "
	echo
}

chaincodeQuery () {
  PEER=$1
  echo "===================== Querying on PEER$PEER on channel '$CHANNEL_NAME'... ===================== "
  setGlobals $PEER
  local rc=1
  local starttime=$(date +%s)

  # continue to poll
  # we either get a successful response, or reach TIMEOUT
#  while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
#  do
     sleep 3
     echo "Attempting to Query PEER$PEER ...$(($(date +%s)-starttime)) secs"
     peer chaincode query -C $CHANNEL_NAME -n $CCNAME -c '{"Args":["GetVersionFunction", "test"]}' >&log.txt
#     test $? -eq 0 && VALUE=$(cat log.txt | awk '/Query Result/ {print $NF}')
#     test "$VALUE" = "$2" && let rc=0
#  done
  echo
  cat log.txt
#  if test $rc -eq 0 ; then
#	echo "===================== Query on PEER$PEER on channel '$CHANNEL_NAME' is successful ===================== "
#  else
#	echo "!!!!!!!!!!!!!!! Query result on PEER$PEER is INVALID !!!!!!!!!!!!!!!!"
#        echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
#	echo
#	exit 1
#  fi
}


## Install chaincode on Peer0/Org1 and Peer2/Org2
echo "Installing chaincode on org1/peer1..."
installChaincode 1
sleep 1s

echo "Install chaincode on org2/peer1..."
installChaincode 2
sleep 1s

echo "Install chaincode on org3/peer1..."
installChaincode 3
sleep 1s

echo "Install chaincode on org4/peer1..."
installChaincode 4
sleep 1s

#Instantiate chaincode on Peer2/Org2
#echo "Instantiating chaincode on org1/peer1..."
instantiateChaincode 1

#Query on chaincode on Peer0/Org1
echo "Querying chaincode on org1/peer1..."
chaincodeQuery 1 100

echo "Querying chaincode on org2/peer1..."
chaincodeQuery 2 100

echo "Querying chaincode on org3/peer1..."
chaincodeQuery 3 100

echo "Querying chaincode on org4/peer1..."
chaincodeQuery 4 100


echo
echo "========= All GOOD, BYFN execution completed =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0
