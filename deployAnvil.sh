#!/bin/zsh
# Usage: ./push_artifacts.sh <chain_id>

# Run anvil.sh in another shell before running this

# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script script/DeployAnvil.s.sol:Deploy --rpc-url "http://127.0.0.1:8545/" --sender $SENDER --private-key $PRIVATE_KEY --broadcast -vvvv

rm web/src/artifacts/*.json

source push_artifacts.sh "DeployAnvil.s.sol/5"

# cd web
# npm run build