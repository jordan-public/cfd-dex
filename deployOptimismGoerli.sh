#!/bin/zsh

# Run anvil.sh in another shell before running this

# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script script/DeployOptimismGoerli.s.sol:Deploy --rpc-url "https://goerli.optimism.io" --sender $SENDER --private-key $PRIVATE_KEY --broadcast -vvvv

source push_artifacts.sh "DeployOptimismGoerli.s.sol/420"

# cd web
# npm run build