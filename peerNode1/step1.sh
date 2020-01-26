rm ./channel-artifacts/*
rm -rf crypto-config/

export FABRIC_CFG_PATH=$PWD


export CHANNEL_NAME=mychannel

# create certificate
../bin/cryptogen generate --config=./crypto-config.yaml

# create genesis.block
../bin/configtxgen -profile SampleDevModeKafka -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block

# create channel.tx
../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

# specify anchor peer org1
../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP

# specify anchor peer org2
../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP

tar -cvf crypto-config.tar crypto-config
tar -cvf channel-artifacts.tar channel-artifacts
