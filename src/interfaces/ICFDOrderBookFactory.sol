// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./ICFDOrderBook.sol";

interface ICFDOrderBookFactory {
    function owner() external view returns (address);

    function createOrderBook(
        address priceFeedAddress,
        address settlementCurrencyAddress,
        uint256 entryMargin,
        uint256 maintenanceMargin,
        uint256 liquidationPentalty,
        uint256 dust
    ) external;

    function getNumOBs() external view returns (uint256);

    function getOB(uint256 id) external view returns (ICFDOrderBook);

    function withfrawFees(uint obId)
        external
        returns (uint256 feesCollected);
}
