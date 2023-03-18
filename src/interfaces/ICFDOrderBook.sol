// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";

interface ICFDOrderBook {
    function getDescription() external view returns (string memory);

    function settlementCurrency() external view returns (IERC20);

    function settlementCurrencyDenominator() external view returns (uint256);

    function priceDenominator() external view returns (uint256);

    function getPrice() external view returns (uint256);

    function numOrdersOwned() external view returns (uint256);

    function numPositions() external view returns (uint256);

    function getOrderId(uint256 index) external view returns(uint256);

    function buy(
        uint256 amount,
        uint256 price
    ) external returns (uint256 orderId, uint256 filled);

    function orderStatus(uint256 orderId)
        external
        view
        returns (
            int256 amount,
            uint256 limitPrice
        );

    function getPositionByAddress() external view returns (int256 holding, uint256 holdingAveragePrice, uint256 collateral, uint256 requiredCollateral);

    function getPosition(uint256 positionId) external view returns(address owner, int256 holding, uint256 holdingAveragePrice, uint256 collateral, uint256 requiredCollateral);

    function cancel(uint256 orderId) external;

    function feesToCollect() external view returns (uint256);

    function withdrawFees(address payTo) external returns (uint256);
}
