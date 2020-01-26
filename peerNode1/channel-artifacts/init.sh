#/bin/sh

. ./env.sh

CHANNEL_NAME="mychannel"
CORE_PEER_LOCALMSPID="Org1MSP"
VERSION="1.0"
LANGUAGE="node"
CC_SRC_PATH="github.com/chaincode/chaincode_example02/node/"

echo "Creating channel..."
setGlobals 0 1
set -x
export CHANNEL_NAME=mychannel
peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
set +x

echo "Having all peers for org1 join the channel..."
setGlobals 0 1
set -x
peer channel join -b mychannel.block
set +x

setGlobals 1 1
set -x
peer channel join -b mychannel.block
set +x

echo "Updating anchor peers for org1..."
setGlobals 0 1
set -x
peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
set +x

echo "Installing chaincode on peer0.org1..."
setGlobals 0 1
set -x
peer chaincode install -n mycc -v 1.0 -l node -p /opt/gopath/src/github.com/chaincode/chaincode_example02/node/
set +x
sleep 3

echo "Installing chaincode on peer1.org1..."
setGlobals 1 1
set -x
peer chaincode install -n mycc -v 1.0 -l node -p /opt/gopath/src/github.com/chaincode/chaincode_example02/node/
set +x
sleep 3

echo "Instantiating chaincode on peer0.org1..."
setGlobals 0 1
set -x
peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n mycc -l node -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')"
set +x
sleep 3

echo "Querying chaincode on peer1.org1..."
setGlobals 1 1
set -x
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
set +x
