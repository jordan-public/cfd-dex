source .env
# Set EUR/USD price to $1
# Example: set EUR/USD price to 1.1 (EUR/USD oracle is 8 decimals):
# ./mockPrice.sh 110000000
# Reset to normal operation:
# ./mockPrice.sh 0
cast send --private-key $PRIVATE_KEY  --rpc-url "http://127.0.0.1:8545/" 0x87B7CF94AfBf2c95213ee82d347d918Be6747a6C "setMockPrice(uint256)()" "$1"

echo "Result:"

# See the result
cast call --rpc-url "http://127.0.0.1:8545/" 0x87B7CF94AfBf2c95213ee82d347d918Be6747a6C "getPrice()(uint256)"