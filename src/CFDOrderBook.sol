// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "chainlink/interfaces/AggregatorV3Interface.sol";
import "./interfaces/ICFDOrderBook.sol";
import "./interfaces/ICFDOrderBookFactory.sol";

contract CFDOrderBook is ICFDOrderBook {
    address public owner;
    IERC20 public settlementCurrency;
    AggregatorV3Interface public priceFeed;
    uint256 settlementCurrencyDecimalsFactor;
    uint256 priceDecimalsFactor;
        
    uint256 public feesToCollect; // = 0;
    uint16 public constant FEE_DENOM = 10000;
    uint16 public constant FEE_TAKER_TO_MAKER = 25; // 0.25%
    uint16 public constant FEE_TAKER_TO_PROTOCOL = 5; // 0.05%

    struct OrderType {
        address owner;
        uint256 amount;
        uint256 price;
        bool isBuy;
    }

    OrderType[] public orders;
    mapping(address => uint256[]) public ordersOwned;
    mapping(uint256 => uint256) public orderIndexes; // Index of the order in the array ordersOwned[owner]
    
    function numOrdersOwned() external view returns (uint256) {
        return ordersOwned[msg.sender].length;
    }

    function getOrderId(uint256 index) external view returns(uint256) {
        if (index >= ordersOwned[msg.sender].length) return 0; // Non-existent
        return ordersOwned[msg.sender][index];
    }

    function getDescription() external view returns (string memory) {
        return priceFeed.description();
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "OrderPool: Unauthorized");
        _;
    }

    modifier onlyEOA() {
        // This may cause a problem with Account Abstraction (see: https://eips.ethereum.org/EIPS/eip-4337)
        // but apparently this will be an optional feature.
        require(
            msg.sender == tx.origin,
            "OrderPool: Cannot call from contract"
        );
        _;
    }

    constructor(
        address priceFeedAddress,
        address settlementCurrencyAddress
    ) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
        settlementCurrency = IERC20(settlementCurrencyAddress);
        settlementCurrencyDecimalsFactor = 10**ERC20(settlementCurrencyAddress).decimals();
        priceDecimalsFactor = 10**priceFeed.decimals();
    }

    // To cover "transfer" calls which return bool and/or revert
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        console.log(
            "safeTransfer caller: %s token: %s",
            msg.sender,
            address(token)
        );
        console.log("to: %s amount: %s", to, amount);
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0xa9059cbb, to, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "OrderPool: transfer failed"
        );
    }

    // To cover "transfer" calls which return bool and/or revert
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        console.log(
            "safeTransferFrom caller: %s token: %s",
            msg.sender,
            address(token)
        );
        console.log("from: %s to: %s amount: %s", from, to, amount);
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0x23b872dd, from, to, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "OrderPool: transferFrom failed"
        );
    }

    function buy(
        uint256 amount,
        uint256 price
    ) external returns (uint256 orderId, uint256 filled) {
//!!!Unimplemented
    }

    function sell(
        uint256 amount,
        uint256 price
    ) external returns (uint256 orderId, uint256 filled){
//!!!Unimplemented
    }

    function orderStatus(uint256 orderId)
        external
        view
        returns (
            uint256 amount,
            uint256 price,
            bool isBuy
        ) {
//!!!Unimplemented
        }

    function cancel(uint256 orderId) external{
//!!!Unimplemented
    }

        function withdrawFees(address payTo)
        external
        onlyOwner
        returns (uint256 collected)
    {
        console.log("withdraw fees");
        safeTransfer(settlementCurrency, payTo, feesToCollect);
        collected = feesToCollect;
        feesToCollect = 0;
    }
}
