## Modified Balance Transfer

### 사전준비
* 기존 docker 컨테이너나 이미지가 있다면 삭제하는 것이 좋다.
```
docker rm -f $(docker ps -aq)
docker rmi -f $(docker images -q)
```

### Node.js rest-api 서버 실행

##### 콘솔창 1 에서 아래 명령어 입력

* docker-compose로 네트워크 시작

```
docker-compose -f artifacts/docker-compose.yaml up
```
##### 콘솔창 2 에서 아래 명령어 입력
* fabric-client와 fabric-ca-client 설치
```
npm install
```
* 4000번 포트로 node app 시작
```
PORT=4000 node app
```

##### 콘솔창 3

* test 스크립트 수행 

```
./testAPIs.sh -l node
```
만약 instanciate 부분에서 timeout 에러가 발생한다면 위 스크립트를 재차 실행해 보자.

### api 사용법.

* 토큰 환경변수에 저장
```
ORG1_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Jim&orgName=Org1')

ORG1_TOKEN=$(echo $ORG1_TOKEN | jq ".token" | sed "s/\"//g")

ORG2_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Barry&orgName=Org2')

ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".token" | sed "s/\"//g")
```

* move 함수 실행 (a에서 b로 10만큼 송금)
```
curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer0.org2.example.com"],
	"fcn":"move",
	"args":["a","b","10"]
}'
```

* swap 함수 실행 (a와 b의 값을 뒤바꾸기)
```
curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer0.org2.example.com"],
	"fcn":"swap",
	"args":["a","b"]
}'
```

* set 함수 실행 (a의 값을 1000으로 설정)
```
curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer0.org2.example.com"],
	"fcn":"set",
	"args":["a","1000"]
}'
```

* query 함수 실행 (a의 값을 확인)
```
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22a%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
```

* query 함수 실행 (b의 값을 확인)
```
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22b%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
```

이하부터는 기존 설명입니다.
## Balance transfer

A sample Node.js app to demonstrate **__fabric-client__** & **__fabric-ca-client__** Node.js SDK APIs

### Prerequisites and setup:

* [Docker](https://www.docker.com/products/overview) - v1.12 or higher
* [Docker Compose](https://docs.docker.com/compose/overview/) - v1.8 or higher
* [Git client](https://git-scm.com/downloads) - needed for clone commands
* **Node.js** v8.4.0 or higher
* [Download Docker images](http://hyperledger-fabric.readthedocs.io/en/latest/samples.html#binaries)

```
cd fabric-samples/balance-transfer/
```

Once you have completed the above setup, you will have provisioned a local network with the following docker container configuration:

* 2 CAs
* A SOLO orderer
* 4 peers (2 peers per Org)

#### Artifacts
* Crypto material has been generated using the **cryptogen** tool from Hyperledger Fabric and mounted to all peers, the orderering node and CA containers. More details regarding the cryptogen tool are available [here](http://hyperledger-fabric.readthedocs.io/en/latest/build_network.html#crypto-generator).
* An Orderer genesis block (genesis.block) and channel configuration transaction (mychannel.tx) has been pre generated using the **configtxgen** tool from Hyperledger Fabric and placed within the artifacts folder. More details regarding the configtxgen tool are available [here](http://hyperledger-fabric.readthedocs.io/en/latest/build_network.html#configuration-transaction-generator).

## Running the sample program

There are two options available for running the balance-transfer sample
For each of these options, you may choose to run with chaincode written in golang or in node.js.

### Option 1:

##### Terminal Window 1

* Launch the network using docker-compose

```
docker-compose -f artifacts/docker-compose.yaml up
```
##### Terminal Window 2

* Install the fabric-client and fabric-ca-client node modules

```
npm install
```

* Start the node app on PORT 4000

```
PORT=4000 node app
```

##### Terminal Window 3

* Execute the REST APIs from the section [Sample REST APIs Requests](https://github.com/hyperledger/fabric-samples/tree/master/balance-transfer#sample-rest-apis-requests)


### Option 2:

##### Terminal Window 1

```
cd fabric-samples/balance-transfer

./runApp.sh

```

* This launches the required network on your local machine
* Installs the fabric-client and fabric-ca-client node modules
* And, starts the node app on PORT 4000

##### Terminal Window 2


In order for the following shell script to properly parse the JSON, you must install ``jq``:

instructions [https://stedolan.github.io/jq/](https://stedolan.github.io/jq/)

With the application started in terminal 1, next, test the APIs by executing the script - **testAPIs.sh**:
```
cd fabric-samples/balance-transfer

## To use golang chaincode execute the following command

./testAPIs.sh -l golang

## OR use node.js chaincode

./testAPIs.sh -l node
```


## Sample REST APIs Requests

### Login Request

* Register and enroll new users in Organization - **Org1**:

`curl -s -X POST http://localhost:4000/users -H "content-type: application/x-www-form-urlencoded" -d 'username=Jim&orgName=Org1'`

**OUTPUT:**

```
{
  "success": true,
  "secret": "RaxhMgevgJcm",
  "message": "Jim enrolled Successfully",
  "token": "<put JSON Web Token here>"
}
```

The response contains the success/failure status, an **enrollment Secret** and a **JSON Web Token (JWT)** that is a required string in the Request Headers for subsequent requests.

### Create Channel request

```
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer <put JSON Web Token here>" \
  -H "content-type: application/json" \
  -d '{
	"channelName":"mychannel",
	"channelConfigPath":"../artifacts/channel/mychannel.tx"
}'
```

Please note that the Header **authorization** must contain the JWT returned from the `POST /users` call

### Join Channel request

```
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer <put JSON Web Token here>" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"]
}'
```
### Install chaincode

```
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer <put JSON Web Token here>" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"chaincodeName":"mycc",
	"chaincodePath":"github.com/example_cc/go",
	"chaincodeType": "golang",
	"chaincodeVersion":"v0"
}'
```
**NOTE:** *chaincodeType* must be set to **node** when node.js chaincode is used and *chaincodePath* must be set to the location of the node.js chaincode. Also put in the $PWD
```
ex:
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer <put JSON Web Token here>" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"chaincodeName":"mycc",
	"chaincodePath":"$PWD/artifacts/src/github.com/example_cc/node",
	"chaincodeType": "node",
	"chaincodeVersion":"v0"
}'
```

### Instantiate chaincode

This is the endorsement policy defined during instantiation.
This policy can be fulfilled when members from both orgs sign the transaction proposal.

```
{
	identities: [{
			role: {
				name: 'member',
				mspId: 'Org1MSP'
			}
		},
		{
			role: {
				name: 'member',
				mspId: 'Org2MSP'
			}
		}
	],
	policy: {
		'2-of': [{
			'signed-by': 0
		}, {
			'signed-by': 1
		}]
	}
}
```

```
curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes \
  -H "authorization: Bearer <put JSON Web Token here>" \
  -H "content-type: application/json" \
  -d '{
	"chaincodeName":"mycc",
	"chaincodeVersion":"v0",
	"chaincodeType": "golang",
	"args":["a","100","b","200"]
}'
```
**NOTE:** *chaincodeType* must be set to **node** when node.js chaincode is used

### Invoke request

This invoke request is signed by peers from both orgs, *org1* & *org2*.
```
curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer <put JSON Web Token here>" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer0.org2.example.com"],
	"fcn":"move",
	"args":["a","b","10"]
}'
```
**NOTE:** Ensure that you save the Transaction ID from the response in order to pass this string in the subsequent query transactions.

### Chaincode Query

```
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22a%22%5D" \
  -H "authorization: Bearer <put JSON Web Token here>" \
  -H "content-type: application/json"
```

### Query Block by BlockNumber

```
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/blocks/1?peer=peer0.org1.example.com" \
  -H "authorization: Bearer <put JSON Web Token here>" \
  -H "content-type: application/json"
```

### Query Transaction by TransactionID

```
curl -s -X GET http://localhost:4000/channels/mychannel/transactions/<put transaction id here>?peer=peer0.org1.example.com \
  -H "authorization: Bearer <put JSON Web Token here>" \
  -H "content-type: application/json"
```
**NOTE**: The transaction id can be from any previous invoke transaction, see results of the invoke request, will look something like `8a95b1794cb17e7772164c3f1292f8410fcfdc1943955a35c9764a21fcd1d1b3`.


### Query ChainInfo

```
curl -s -X GET \
  "http://localhost:4000/channels/mychannel?peer=peer0.org1.example.com" \
  -H "authorization: Bearer <put JSON Web Token here>" \
  -H "content-type: application/json"
```

### Query Installed chaincodes

```
curl -s -X GET \
  "http://localhost:4000/chaincodes?peer=peer0.org1.example.com&type=installed" \
  -H "authorization: Bearer <put JSON Web Token here>" \
  -H "content-type: application/json"
```

### Query Instantiated chaincodes

```
curl -s -X GET \
  "http://localhost:4000/chaincodes?peer=peer0.org1.example.com&type=instantiated" \
  -H "authorization: Bearer <put JSON Web Token here>" \
  -H "content-type: application/json"
```

### Query Channels

```
curl -s -X GET \
  "http://localhost:4000/channels?peer=peer0.org1.example.com" \
  -H "authorization: Bearer <put JSON Web Token here>" \
  -H "content-type: application/json"
```

### Clean the network

The network will still be running at this point. Before starting the network manually again, here are the commands which cleans the containers and artifacts.

```
docker rm -f $(docker ps -aq)
docker rmi -f $(docker images | grep dev | awk '{print $3}')
rm -rf fabric-client-kv-org[1-2]
```

### Network configuration considerations

You have the ability to change configuration parameters by either directly editing the network-config.yaml file or provide an additional file for an alternative target network. The app uses an optional environment variable "TARGET_NETWORK" to control the configuration files to use. For example, if you deployed the target network on Amazon Web Services EC2, you can add a file "network-config-aws.yaml", and set the "TARGET_NETWORK" environment to 'aws'. The app will pick up the settings inside the "network-config-aws.yaml" file.

#### IP Address** and PORT information

If you choose to customize your docker-compose yaml file by hardcoding IP Addresses and PORT information for your peers and orderer, then you MUST also add the identical values into the network-config.yaml file. The url and eventUrl settings will need to be adjusted to match your docker-compose yaml file.

```
peer1.org1.example.com:
  url: grpcs://x.x.x.x:7056
  eventUrl: grpcs://x.x.x.x:7058

```

#### Discover IP Address

To retrieve the IP Address for one of your network entities, issue the following command:

```
# this will return the IP Address for peer0
docker inspect peer0 | grep IPAddress
```

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
