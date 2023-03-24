// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "./interfaces/IFlashCollateralBeneficiary.sol";
import "./interfaces/ICFDOrderBook.sol";

contract FlashLiquidate is IFlashCollateralBeneficiary {
    ICFDOrderBook public cfdOrderBook;
    uint256[] positionIds;
    uint256[] orderIds;
    int256[] amounts;

    constructor(address _cfdOrderBook) {
        cfdOrderBook = ICFDOrderBook(_cfdOrderBook);
    }

    function callBack() external {
        assert(msg.sender == address(cfdOrderBook)); // Must call the given FTSwap
        // do the work
        // Liquidate positions
        for (uint256 i =0; i<positionIds.length; i++) {
            cfdOrderBook.liquidate(positionIds[i]);
        }
        // Take orders to counterbalance
        for (uint256 i = 0; i<orderIds.length; i++) {
            cfdOrderBook.take(orderIds[i], amounts[i]);
        }
    }

    function liquidate(uint256 desiredCollateral, uint256[] memory _positionIds, uint256[] memory _orderIds, int256[] memory _amounts) external {
        require(_orderIds.length == _amounts.length, "Parameter mismatch");
        positionIds = _positionIds;
        orderIds = _orderIds;
        amounts = _amounts;
        cfdOrderBook.flashCollateralizeAndExecute(desiredCollateral);
        uint256 w = cfdOrderBook.withdrawMax();
        cfdOrderBook.settlementCurrency().transfer(msg.sender, w);
        console.log("Flash collateral profit: ", w);
    }
}
