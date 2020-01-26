#!/bin/sh

. ./env.sh

CHANNEL_NAME="mychannel"
CORE_PEER_LOCALMSPID="Org2MSP"
VERSION="1.0"
LANGUAGE="node"
CC_SRC_PATH="github.com/chaincode/chaincode_example02/node/"

echo "Fetching genesis block.."
setGlobals 0 2
set -x
peer channel fetch 0 mychannel.block -c mychannel --orderer orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
set +x

echo "Having all peers for org2 join the channel..."
setGlobals 0 2
set -x
peer channel join -b mychannel.block
set +x

setGlobals 1 2
set -x
peer channel join -b mychannel.block
set +x

echo "Updating anchor peers for org2..."
setGlobals 0 2
set -x
peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
set +x

echo "Installing chaincode on peer0.org2..."
setGlobals 0 2
set -x
peer chaincode install -n mycc -v 1.0 -l node -p /opt/gopath/src/github.com/chaincode/chaincode_example02/node/
set +x
sleep 3

echo "Installing chaincode on peer1.org2..."
setGlobals 1 2
set -x
peer chaincode install -n mycc -v 1.0 -l node -p /opt/gopath/src/github.com/chaincode/chaincode_example02/node/
set +x
sleep 3


echo "Querying chaincode on peer0.org2..."
setGlobals 0 2
set -x
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
set +x
sleep 3

echo "Querying chaincode on peer1.org2..."
setGlobals 1 2
set -x
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
set +x

