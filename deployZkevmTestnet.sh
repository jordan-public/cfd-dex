#!/bin/zsh

# Run anvil.sh in another shell before running this

# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script script/DeployZkevmTestnet.s.sol:Deploy --legacy --rpc-url "https://rpc.public.zkevm-test.net" --sender $SENDER --private-key $PRIVATE_KEY --broadcast -vvvv

source push_artifacts.sh "DeployZkevmTestnet.s.sol/1442"

# cd web
# npm run build