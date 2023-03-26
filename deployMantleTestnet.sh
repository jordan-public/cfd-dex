#!/bin/zsh

# Run anvil.sh in another shell before running this

# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script script/DeployMantleTestnet.s.sol:Deploy --slow --legacy --rpc-url "https://rpc.testnet.mantle.xyz" --sender $SENDER --private-key $PRIVATE_KEY --broadcast -vvvv

source push_artifacts.sh "DeployMantleTestnet.s.sol/5001"

# cd web
# npm run build