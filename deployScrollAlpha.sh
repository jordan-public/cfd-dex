#!/bin/zsh

# Run anvil.sh in another shell before running this

# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script script/DeployScrollAlpha.s.sol:Deploy --legacy --rpc-url "https://alpha-rpc.scroll.io/l2" --sender $SENDER --private-key $PRIVATE_KEY --broadcast -vvvv

source push_artifacts.sh "DeployScrollAlpha.s.sol/534353"

# cd web
# npm run build