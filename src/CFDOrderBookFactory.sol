// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./CFDOrderBook.sol";
import "./interfaces/ICFDOrderBookFactory.sol";

contract CFDOrderBookFactory is ICFDOrderBookFactory {
    address public owner;

    ICFDOrderBook[] obList;

    modifier onlyOwner() {
        require(msg.sender == owner, "CFDOrderBookFactory: Unauthorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function getNumOBs() external view returns (uint256) {
        return obList.length;
    }

    function getOB(uint256 id) external view returns (ICFDOrderBook) {
        return obList[id];
    }

    function createOrderBook(
        address priceFeedAddress,
        address settlementCurrencyAddress,
        uint256 entryMargin,
        uint256 maintenanceMargin,
        uint256 liquidationPentalty
    ) external onlyOwner {
        ICFDOrderBook p = new CFDOrderBook(
            priceFeedAddress,
            settlementCurrencyAddress,
            entryMargin,
            maintenanceMargin,
            liquidationPentalty
        );
        obList.push(p); // Duplicates possible - no harm done
    }

    function withfrawFees(uint256 obId)
        external
        onlyOwner
        returns (uint256 feesCollected)
    {
        ICFDOrderBook p = obList[obId];
        feesCollected = p.withdrawFees(msg.sender);
    }
}
