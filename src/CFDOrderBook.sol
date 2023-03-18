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
    uint256 public settlementCurrencyDenominator;
    uint256 public priceDenominator;
    uint256 entryMargin;
    uint256 maintenanceMargin;
    uint256 liquidationPentalty;
        
    uint256 public feesToCollect; // = 0;
    uint16 public constant FEE_DENOM = 10000;
    uint16 public constant FEE_TAKER_TO_MAKER = 25; // 0.25%
    uint16 public constant FEE_TAKER_TO_PROTOCOL = 5; // 0.05%

    struct OrderType {
        address owner;
        int256 amount;
        uint256 limitPrice;
    }

    OrderType[] public orders;
    mapping(address => uint256[]) public ordersOwned;
    mapping(uint256 => uint256) public orderIds; // Index of the order in the array ordersOwned[owner]

    struct PositionType {
        address owner;
        int256 holding;
        uint256 holdingAveragePrice;
        uint256 collateral;
    }
    
    PositionType[] public positions;
    mapping(address => uint256) public positionIds;

    function numPositions() external view returns (uint256) {
        return positions.length;
    }

    function getPositionByAddress() external view returns (int256 holding, uint256 holdingAveragePrice, uint256 collateral, uint256 requiredCollateral) {
        uint256 positionId = positionIds[msg.sender];
        address o;
        (o, holding, holdingAveragePrice, collateral, requiredCollateral) = getPosition(positionId);
    }
 
    function getPosition(uint256 positionId) public view returns(address positionOwner, int256 holding, uint256 holdingAveragePrice, uint256 collateral, uint256 requiredCollateral) {
        require(positionId < positions.length, "Non existent position");
        positionOwner  = positions[positionId].owner;
        holding = positions[positionId].holding;
        holdingAveragePrice = positions[positionId].holdingAveragePrice;
        collateral = positions[positionId].collateral;
        int256 price = int256(getPrice());
        int256 profit = (holding * (price - int(holdingAveragePrice))) / int256(priceDenominator);
        int256 r = abs((((price * holding) / int256(priceDenominator)) * int256(maintenanceMargin)) / int256(1 ether)) - profit;
        requiredCollateral = uint256(r<0 ? int256(0) : r);
    }

    function abs(int256 x) pure internal returns (int256) {
        return x>0 ? x : -x;
    }

    function getPrice() public view returns (uint256 price) {
        (, int256 feedPrice, , , ) = priceFeed.latestRoundData();
        require(feedPrice > 0, "Invalid price");
        price = uint256(feedPrice);
    }

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

    constructor(
        address priceFeedAddress,
        address settlementCurrencyAddress,
        uint256 _entryMargin,
        uint256 _maintenanceMargin,
        uint256 _liquidationPentalty
    ) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
        settlementCurrency = IERC20(settlementCurrencyAddress);
        settlementCurrencyDenominator = 10**ERC20(settlementCurrencyAddress).decimals();
        priceDenominator = 10**priceFeed.decimals();
        entryMargin = _entryMargin;
        maintenanceMargin = _maintenanceMargin;
        liquidationPentalty = _liquidationPentalty;
        positions.push(PositionType(address(0), 0, 0, 0)); // Empty position
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
        uint256 limitPrice
    ) external returns (uint256 orderId, uint256 filled) {
//!!!Unimplemented
    }

    function orderStatus(uint256 orderId)
        external
        view
        returns (
            int256 amount,
            uint256 limitPrice
        ) {
        require(orderId < orders.length, "Non existent order");
        amount = orders[orderId].amount;
        limitPrice = orders[orderId].limitPrice;
    }

    function cancelOrder(uint256 orderId) internal {
        orders[orderId].amount = 0;
    }

    function cancel(uint256 orderId) external {
        require(orderId < orders.length, "Non exsitent order");
        require(msg.sender == orders[orderId].owner);
        cancelOrder(orderId);
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
