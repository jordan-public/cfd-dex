#!/bin/zsh

# Run anvil.sh in another shell before running this

# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script script/DeployTaikoAlpha-2.s.sol:Deploy --rpc-url "https://rpc.a2.taiko.xyz" --sender $SENDER --private-key $PRIVATE_KEY --broadcast -vvvv

source push_artifacts.sh "DeployTaikoAlpha-2.s.sol/167004"

# cd web
# npm run build