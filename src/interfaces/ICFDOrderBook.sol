// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";

interface ICFDOrderBook {
    function getDescription() external view returns (string memory);

    function settlementCurrency() external view returns (IERC20);

    function numOrdersOwned() external view returns (uint256);

    function getOrderId(uint256 index) external view returns(uint256);

    function buy(
        uint256 amount,
        uint256 price
    ) external returns (uint256 orderId, uint256 filled);

    function sell(
        uint256 amount,
        uint256 price
    ) external returns (uint256 orderId, uint256 filled);

    function orderStatus(uint256 orderId)
        external
        view
        returns (
            uint256 amount,
            uint256 price,
            bool isBuy
        );

    function cancel(uint256 orderId) external;

    function feesToCollect() external view returns (uint256);

    function withdrawFees(address payTo) external returns (uint256);
}
