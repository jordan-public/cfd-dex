// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "chainlink/interfaces/AggregatorV3Interface.sol";

// This is a mock Chainlink compatible proce feed oracle, which serves a pegged price.
contract MockPriceFeedOracle is AggregatorV3Interface {
    uint8 public decimals = 8;
    string public description = "CNY / USD";
    uint256 public version = 1;
    int256 PEG = int256((10 ** decimals * 10000) / 68680);

    function getRoundData(
        uint80
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (0, PEG, 0, 0, 0);
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (0, PEG, 0, 0, 0);
    }
}
