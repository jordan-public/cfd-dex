#!/bin/zsh

# Run anvil.sh in another shell before running this

# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script script/DeployZksyncEraTestnet.s.sol:Deploy --rpc-url "https://testnet.era.zksync.dev" --sender $SENDER --private-key $PRIVATE_KEY --broadcast -vvvv

source push_artifacts.sh "DeployZksyncEraTestnet.s.sol/280"

# cd web
# npm run build