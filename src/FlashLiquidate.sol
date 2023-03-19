// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./interfaces/IFlashCollateralBeneficiary.sol";
import "./interfaces/ICFDOrderBook.sol";

contract FlashLiquidate is IFlashCollateralBeneficiary {
    ICFDOrderBook public cfdOrderBook;
    uint256[] orderIds;
    int256[] amounts;

    constructor(address _cfdOrderBook) {
        cfdOrderBook = ICFDOrderBook(_cfdOrderBook);
    }

    function callBack() external {
        assert(msg.sender == address(cfdOrderBook)); // Must call the given FTSwap
        // do the work
        for (uint256 i = 0; i<orderIds.length; i++) {
            cfdOrderBook.take(orderIds[i], amounts[i]);
        }
    }

    function liquidate(uint256 desiredCollateral, uint256[] memory _orderIds, int256[] memory _amounts) external {
        require(_orderIds.length == _amounts.length, "Parameter mismatch");
        orderIds = _orderIds;
        amounts = _amounts;
        cfdOrderBook.flashCollateralizeAndExecute(desiredCollateral);
    }
}
