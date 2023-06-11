#!/usr/bin/env bash

# go to current folder
cd "$(dirname "$0")"

# build
make build || exit 1
./cmd/ipfs/ipfs --version || exit 1

# kill process using port 5001 if any
fuser -k 5001/tcp

# start pubsub daemon
rm -fr test-pubsub-ipfs
IPFS_PATH=test-pubsub-ipfs ./cmd/ipfs/ipfs init
IPFS_PATH=test-pubsub-ipfs ./cmd/ipfs/ipfs daemon --enable-pubsub-experiment &

# wait for pubsub daemon to open
echo "wait for pubsub daemon on port 5001..."
while ! nc -z localhost 5001; do   
  sleep 0.1
done

# sub
IPFS_PATH=test-pubsub-ipfs ./cmd/ipfs/ipfs pubsub sub "12D3KooWG3XbzoVyAE6Y9vHZKF64Yuuu4TjdgQKedk14iYmTEPWu" --enc=json &
sleep 1

# pub
# echo hellp | IPFS_PATH=test-pubsub-ipfs ./cmd/ipfs/ipfs pubsub pub "test-topic"
# sleep 1

SCRIPT="
const Plebbit = require('../plebbit-js')
;(async () => {
  const plebbit = await Plebbit({pubsubHttpClientsOptions: ['http://localhost:5001/api/v0'], ipfsGatewayUrls: ['https://ipfsgateway.xyz']})
  plebbit.on('error', error => console.log('plebbit error:', error.message))
  const signer = await plebbit.createSigner()
  const comment = await plebbit.createComment({signer, title: 'title', content: 'content', subplebbitAddress: '12D3KooWG3XbzoVyAE6Y9vHZKF64Yuuu4TjdgQKedk14iYmTEPWu'})
  await comment.publish()
})()
"

node -e "$SCRIPT"

# clean up
# fuser -k 5001/tcp
# rm -fr test-pubsub-ipfs
# exit 0
