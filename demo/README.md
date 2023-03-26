# Demo

## Video

## Deployments

For instructions on how to deploy the contracts and the front-end on a local development environment, as well as various testnets check [here](../HOWTO.md).

Most testnets lack the desired Chainlink price feed oracles. Also, it is hard to get large amounts of USDC on testnets for experimentation. To mitigate these problems we have created the following:
- A mock USD (IERC20 + "mint(uint256)") token with symbol MUSD. Anyone can call the method "mint(uint256 amount)" on the contract to mint any amount of MUSD (up to $2^{50}$). 
- A mock Chainlink-compatible (AggregatorV3Interface) oracle, which delivers a fixed price for CNY/USD. In order to experiment with the price dynamics, the contract CFDOrderBook provides a method "setMockPrice(uint256 price)" which can be called by anyone to set the oracle price to any value (in 8 decimal places). To reset it to the default value, call "setMockPrice(0)". 

The contract calls can be conveniently executed from the appropriate blockchain explorer.

This is how all the testned deployments look after connecting with a wallet:
![TestnetFrontEnd](./TestnetFrontEnd-opg.png)

Here are the deployed contract addresses (no, it's not a mistake that they are the same on different blockchains - I am using the same addresses, signatures and sequence of deployment):

![](gnosis.jpeg) Gnosis Chiado:
```
MUSD: 0xe7a044e19D5afbB2957740a3Cdc3E295F152CF7E
MockPriceFeedOracle: 0x945923132F617Aa5d1bF4E6ea1baCa041Cc9fBEa
CFDOrderBookFactory: 0xaF4cF2Fdd4518615fCd7C82B1b4a9c5818296C26
CFDOrderBook for CNY/USD: 0xe0C7880061074fC21c4ce3CC9C1a9bF132462af1
FlashLiquidate for CNY/USD: 0x5213cA4f2dC60E925E8712d4b1f7d2D0976A5617
```

![](optimism.jpeg) Optimism Görli:
```
MUSD: 0xe7a044e19D5afbB2957740a3Cdc3E295F152CF7E
MockPriceFeedOracle: 0x945923132F617Aa5d1bF4E6ea1baCa041Cc9fBEa
CFDOrderBookFactory: 0xaF4cF2Fdd4518615fCd7C82B1b4a9c5818296C26
CFDOrderBook for CNY/USD: 0xe0C7880061074fC21c4ce3CC9C1a9bF132462af1
FlashLiquidate for CNY/USD: 0x5213cA4f2dC60E925E8712d4b1f7d2D0976A5617
```

![](scroll.png) Scroll Alpha:
```
MUSD: 0xe7a044e19D5afbB2957740a3Cdc3E295F152CF7E
MockPriceFeedOracle: 0x945923132F617Aa5d1bF4E6ea1baCa041Cc9fBEa
CFDOrderBookFactory: 0xaF4cF2Fdd4518615fCd7C82B1b4a9c5818296C26
CFDOrderBook for CNY/USD: 0xe0C7880061074fC21c4ce3CC9C1a9bF132462af1
FlashLiquidate for CNY/USD: 0x5213cA4f2dC60E925E8712d4b1f7d2D0976A5617
```

![](polygon.png) Polygon zkEVM Testnet:
```
MUSD: 0x945923132F617Aa5d1bF4E6ea1baCa041Cc9fBEa
MockPriceFeedOracle: 0xaF4cF2Fdd4518615fCd7C82B1b4a9c5818296C26
CFDOrderBookFactory: 0x913d673428f0c24803EF612213d0760B5799C833
CFDOrderBook for CNY/USD: 0x7428F21D1Fd609B4FFcE31F75A7b7e233dE562aB
FlashLiquidate for CNY/USD: 0x47a9ebAF9b3C8aE77251249c3ab47FaF0bd46A2e
```

![](mantle.png) Mantle Testnet:
```
MUSD: 0x5213cA4f2dC60E925E8712d4b1f7d2D0976A5617
MockPriceFeedOracle: 0x47a9ebAF9b3C8aE77251249c3ab47FaF0bd46A2e
CFDOrderBookFactory: 0xc41b5FF86Fc2250CfF87E573723220abC4e05578
CFDOrderBook for CNY/USD: 0x9ff069C602261b6D26C27D2827Bc9F324a88C474
FlashLiquidate for CNY/USD: 0x1d3f9dEB07dBC53dB803bAEAA412D4aaf012DA6e

```

![](taiko.jpeg) Taiko Alpha-2 ([click here for web3 app](https://bafybeifmi7asmz7xasqus67n6xrtfxc7aj42ys5ocg3h3s3a3w422ijfey.ipfs.dweb.link)):
```
MUSD: 0x945923132F617Aa5d1bF4E6ea1baCa041Cc9fBEa
MockPriceFeedOracle: 0xaF4cF2Fdd4518615fCd7C82B1b4a9c5818296C26
CFDOrderBookFactory: 0x913d673428f0c24803EF612213d0760B5799C833
CFDOrderBook for CNY/USD: 0x7428F21D1Fd609B4FFcE31F75A7b7e233dE562aB
FlashLiquidate for CNY/USD: 0x47a9ebAF9b3C8aE77251249c3ab47FaF0bd46A2e

```

![](zksync.png) zkSync Era Testnet :

This is work in progress. The contracts can be compiled manually, but I have not managed to set up the Foundry toolkit to use the zkSync Era Solidity LLVM compiler.
