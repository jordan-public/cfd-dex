// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/interfaces/IERC20.sol";
   
interface ICFDOrderBook {
    function getDescription() external view returns (string memory);

    function settlementCurrency() external view returns (IERC20);

    function settlementCurrencyDenominator() external view returns (uint256);

    function priceDenominator() external view returns (uint256);

    function getPrice() external view returns (uint256);

    function numOrders() external view returns (uint256);

    function numOrdersOwned() external view returns (uint256);

    function numPositions() external view returns (uint256);

    function getOrderId(uint256 index) external view returns (uint256);

    function make(int256 amount, uint256 limitPrice)
        external
        returns (uint256 orderId);

    function take(uint256 orderId, int256 amount) external;

    function orderStatus(uint256 orderId)
        external
        view
        returns (address owner, int256 amount, uint256 limitPrice);

    function getRequiredEntryCollateral(uint256 positionId, uint256 tradePrice) external view returns (int256);
    
    function getMyPosition()
        external
        view
        returns (
            int256 holding,
            int256 holdingAveragePrice,
            int256 collateral,
            int256 liquidationCollateralLevel,
            int256 unrealizedGain
        );

    function getPosition(uint256 positionId)
        external
        view
        returns (
            address owner,
            int256 holding,
            int256 holdingAveragePrice,
            int256 collateral,
            int256 liquidationCollateralLevel,
            int256 unrealizedGain
        );

    function cancel(uint256 orderId) external;

    function feesToCollect() external view returns (uint256);

    function withdrawFees(address payTo) external returns (uint256);

    function flashCollateralizeAndExecute(uint256 desiredCollateral) external;
}
