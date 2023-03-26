// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/interfaces/IERC20.sol";
import "chainlink/interfaces/AggregatorV3Interface.sol";
import "./interfaces/IFlashCollateralBeneficiary.sol";
import "./interfaces/ICFDOrderBook.sol";
import "./interfaces/ICFDOrderBookFactory.sol";

// Pricing decimals:
// - The collateral is priced in the amount of decimal places of the collateral token.
//   For example, USDC has 6 decimals
// - The CFD underlying asset is priced in the amount of decimals that the oracle provides.
//   For example "EUR/USD" pricing provided by ChainLink has 8 decimals.
// - The amounts of the underlying asset is always priced in 18 decimals (1 ether / 1 wei).
//   For example, 1M EUR/USD would be represented ad 10**6 * 10**18
// - The value of the CFD and the P/L is priced in the same amount of decimals as the
//   collateral. This is because this value has to be directly comparable to the collateral.
//   For example, 1M worth of EUR/USD at price 1.1 when USDC is used as collateral
//   would be represented as 1.1 * 10**6 * 10**6, which is 1.1M with 6 decimals.

contract CFDOrderBook is ICFDOrderBook {
    address public owner;
    IERC20 public settlementCurrency;
    AggregatorV3Interface public priceFeed;
    uint256 public settlementCurrencyDenominator;
    uint256 public priceDenominator;
    // BTW, position amounts and collaterals are always 18 decimals (1 ether)
    uint256 public entryMargin;
    uint256 public maintenanceMargin;
    uint256 public liquidationPentalty;
    uint256 public dust;

    uint256 mockPrice; // = 0; for testing

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
    uint256 numActiveOrders; // = 0

    struct PositionType {
        address owner;
        int256 holding;
        int256 holdingAveragePrice;
        int256 collateral;
    }

    PositionType[] public positions;
    mapping(address => uint256) public positionIds;

    function numPositions() external view returns (uint256) {
        return positions.length;
    }

    function getMyPosition()
        external
        view
        returns (
            uint256 id,
            int256 holding,
            int256 holdingAveragePrice,
            int256 collateral,
            int256 liquidationCollateralLevel,
            int256 unrealizedGain
        )
    {
        id = positionIds[msg.sender];
        (
            ,
            holding,
            holdingAveragePrice,
            collateral,
            liquidationCollateralLevel,
            unrealizedGain
        ) = getPosition(id);
    }

    // Assumes transaction executed optimistically at tradePrice
    function getRequiredEntryCollateral(
        uint256 positionId,
        uint256 tradePrice
    ) public view returns (int256) {
        int256 positionValue = (((positions[positionId].holding *
            int256(tradePrice)) / int256(priceDenominator)) *
            int256(settlementCurrencyDenominator)) / 1 ether;
        return
            abs(positionValue * int256(entryMargin)) /
            int256(1 ether) -
            getUnrealizedGain(positionId, tradePrice);
    }

    function getLiquidationCollateral(
        uint256 positionId
    ) internal view returns (int256) {
        uint256 p = getPrice();
        int256 positionValue = (((positions[positionId].holding * int256(p)) /
            int256(priceDenominator)) * int256(settlementCurrencyDenominator)) /
            1 ether;
        return
            abs(positionValue * int256(maintenanceMargin)) /
            int256(1 ether) -
            getUnrealizedGain(positionId, p);
    }

    function getUnrealizedGain(
        uint256 positionId,
        uint256 price
    ) internal view returns (int256) {
        return
            (((positions[positionId].holding *
                (int256(price) - positions[positionId].holdingAveragePrice)) /
                int256(priceDenominator)) *
                int256(settlementCurrencyDenominator)) / 1 ether;
    }

    function getPosition(
        uint256 positionId
    )
        public
        view
        returns (
            address positionOwner,
            int256 holding,
            int256 holdingAveragePrice,
            int256 collateral,
            int256 liquidationCollateralLevel,
            int256 unrealizedGain
        )
    {
        require(positionId < positions.length, "Non existent position");
        positionOwner = positions[positionId].owner;
        holding = positions[positionId].holding;
        holdingAveragePrice = positions[positionId].holdingAveragePrice;
        collateral = positions[positionId].collateral;
        liquidationCollateralLevel = getLiquidationCollateral(positionId);
        unrealizedGain = getUnrealizedGain(positionId, getPrice());
    }

    function averagePrice(
        int256 holding,
        int256 holdingAveragePrice,
        int256 addHolding,
        uint256 addHoldingPrice
    ) internal pure returns (int256) {
        int256 totalValueNumerator = holding *
            holdingAveragePrice +
            addHolding *
            int256(addHoldingPrice);
        int256 totalHolding = holding + addHolding;
        // Both above are signed values
        if (totalHolding == 0) return 0; // todo: account for possibility of extremely small holding (dust)
        return totalValueNumerator / totalHolding;
    }

    // Takes over the liquidated position
    function liquidate(uint256 positionId) external {
        uint256 myPositionId = positionIds[msg.sender];
        require(myPositionId != 0, "Caller has no funds");
        require(myPositionId != positionId, "Self liquidation forbidden");
        int256 liquidationCollateral = getLiquidationCollateral(positionId);
        require(
            positions[positionId].collateral <= liquidationCollateral,
            "Cannot liquidate"
        );

        uint256 priceAtLiquidation = getPrice();

        // Liquidate optimistically
        int256 penalty = ((liquidationCollateral -
            positions[positionId].collateral) * int256(liquidationPentalty)) /
            int256(1 ether); // Penalty

        int256 valueHeld = positions[positionId].collateral +
            getUnrealizedGain(positionId, priceAtLiquidation);
        require(valueHeld >= 0, "Position insolvent");
        positions[positionId].collateral = valueHeld; // Realize gain as position is taken over (may be negative)

        if (penalty > positions[positionId].collateral)
            penalty = positions[positionId].collateral; // Take as much as possible (there may not be enough)
        positions[positionId].collateral -= penalty;
        positions[myPositionId].collateral += penalty;

        positions[myPositionId].holdingAveragePrice = averagePrice(
            positions[myPositionId].holding,
            positions[myPositionId].holdingAveragePrice,
            positions[positionId].holding,
            priceAtLiquidation
        );
        positions[myPositionId].holding += positions[positionId].holding; // Take over entire holding
        positions[positionId].holding = 0;
        positions[positionId].holdingAveragePrice = 0;

        // Now enforce collateralization of takeover position
        require(
            positions[myPositionId].collateral >=
                getRequiredEntryCollateral(myPositionId, priceAtLiquidation),
            "Insufficient funds"
        );
    }

    function deposit(uint256 amount) external {
        safeTransferFrom(settlementCurrency, msg.sender, address(this), amount);
        uint256 myPositionId = positionIds[msg.sender];
        if (myPositionId == 0) {
            // No position
            // Create position
            myPositionId = positions.length;
            positions.push();
            positionIds[msg.sender] = myPositionId;
            positions[myPositionId].owner = msg.sender;
        }
        positions[myPositionId].collateral += int256(amount);
    }

    function withdraw(uint256 amount) external {
        uint256 myPositionId = positionIds[msg.sender];
        require(
            positions[myPositionId].collateral >=
                getRequiredEntryCollateral(myPositionId, getPrice()) +
                    int256(amount),
            "Insufficient collateral"
        );
        positions[myPositionId].collateral -= int256(amount);
        safeTransfer(settlementCurrency, msg.sender, amount);
    }

    function withdrawMax() public returns (uint256 amount) {
        uint256 myPositionId = positionIds[msg.sender];
        int256 amountWithdrawable = positions[myPositionId].collateral -
            getRequiredEntryCollateral(myPositionId, getPrice());
        if (amountWithdrawable <= 0) return 0;
        positions[myPositionId].collateral -= amountWithdrawable;
        amount = uint256(amountWithdrawable);
        safeTransfer(settlementCurrency, msg.sender, amount);
    }

    function abs(int256 x) internal pure returns (int256) {
        return x > 0 ? x : -x;
    }

    function sgn(int256 x) internal pure returns (int256) {
        return x > 0 ? int256(1) : int256(-1);
    }

    function getPrice() public view returns (uint256 price) {
        if (mockPrice != 0) return mockPrice;
        (, int256 feedPrice, , , ) = priceFeed.latestRoundData();
        require(feedPrice > 0, "Invalid price");
        price = uint256(feedPrice);
    }

    // DANGEROUS!!! WARNING - Use only for testing! Remove before mainnet deployment.
    function setMockPrice(uint256 price) external {
        // require(msg.sender == ICFDOrderBookFactory(owner).owner(), "Unauthorized");
        mockPrice = price;
    }

    function numOrders() external view returns (uint256) {
        return orders.length;
    }

    function numOrdersOwned() external view returns (uint256) {
        return ordersOwned[msg.sender].length;
    }

    function getOrderId(uint256 index) external view returns (uint256) {
        if (index >= ordersOwned[msg.sender].length) return 0; // Non-existent
        return ordersOwned[msg.sender][index];
    }

    function getDescription() external view returns (string memory) {
        return priceFeed.description();
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    constructor(
        address priceFeedAddress,
        address settlementCurrencyAddress,
        uint256 _entryMargin,
        uint256 _maintenanceMargin,
        uint256 _liquidationPentalty,
        uint256 _dust
    ) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
        settlementCurrency = IERC20(settlementCurrencyAddress);
        settlementCurrencyDenominator =
            10 ** IERC20(settlementCurrencyAddress).decimals();
        priceDenominator = 10 ** priceFeed.decimals();
        entryMargin = _entryMargin;
        maintenanceMargin = _maintenanceMargin;
        liquidationPentalty = _liquidationPentalty;
        dust = _dust;
        positions.push(PositionType(address(0), 0, 0, 0)); // Empty position (sentinel)
    }

    // To cover "transfer" calls which return bool and/or revert
    function safeTransfer(IERC20 token, address to, uint256 amount) internal {
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
            "Transfer failed"
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
            "TransferFrom failed"
        );
    }

    function make(
        int256 amount,
        uint256 limitPrice
    ) external returns (uint256 orderId) {
        require(abs(amount) > int256(dust), "Dust");
        uint256 myPositionId = positionIds[msg.sender];
        require(myPositionId != 0, "No collateral");
        // Hypothetically execute trade
        int256 originalHoldingAveragePrice = positions[myPositionId]
            .holdingAveragePrice;
        positions[myPositionId].holdingAveragePrice = averagePrice(
            positions[myPositionId].holding,
            positions[myPositionId].holdingAveragePrice,
            amount,
            limitPrice
        );
        positions[myPositionId].holding += amount;
        // Check collateralization under hypothesis
        require(
            positions[myPositionId].collateral >=
                getRequiredEntryCollateral(myPositionId, limitPrice),
            "Undercollateralized"
        );
        // Roll back hypothesis
        positions[myPositionId].holding -= amount;
        positions[myPositionId]
            .holdingAveragePrice = originalHoldingAveragePrice;
        // Create order book entry
        orderId = orders.length;
        orders.push(OrderType(msg.sender, amount, limitPrice));
        ordersOwned[msg.sender].push(orderId);
        numActiveOrders++;
    }

    // amount < 0 means sell, while the orders[orderId].amount must be > 0
    // and vice versa
    function take(uint256 orderId, int256 amount) public {
        require(abs(amount) > int256(dust), "Minimal trade quantity");
        require(abs(orders[orderId].amount) > int256(dust), "Empty Maker");
        require(
            abs(orders[orderId].amount) >= abs(amount),
            "Taker exceeding maker size"
        );
        require(
            sgn(orders[orderId].amount) != sgn(amount),
            "Maker and Taker on same side"
        );
        // require(
        //     abs(orders[orderId].amount + amount) > int256(dust) || abs(orders[orderId].amount + amount) == 0,
        //     "Dust remainder"
        // );
        uint256 myPositionId = positionIds[msg.sender];
        require(myPositionId != 0, "No collateral");
        uint256 makerPositionId = positionIds[orders[orderId].owner];

        // Optimistically execute order
        orders[orderId].amount += amount;

        positions[myPositionId].holdingAveragePrice = averagePrice(
            positions[myPositionId].holding,
            positions[myPositionId].holdingAveragePrice,
            amount,
            orders[orderId].limitPrice
        );
        positions[myPositionId].holding += amount;

        positions[makerPositionId].holdingAveragePrice = averagePrice(
            positions[makerPositionId].holding,
            positions[makerPositionId].holdingAveragePrice,
            -amount,
            orders[orderId].limitPrice
        );
        positions[makerPositionId].holding -= amount;

        // Now enforce collateralization
        require(
            positions[myPositionId].collateral >=
                getRequiredEntryCollateral(
                    myPositionId,
                    orders[orderId].limitPrice
                ),
            "Undercollateralized taker"
        );
        require(
            positions[makerPositionId].collateral >=
                getRequiredEntryCollateral(
                    makerPositionId,
                    orders[orderId].limitPrice
                ),
            "Undercollateralized maker"
        );

        // Clenan-up order
        if (abs(orders[orderId].amount) <= int256(dust)) {
            numActiveOrders--;
            cancelOrder(orderId);
        }
    }

    function orderStatus(
        uint256 orderId
    )
        external
        view
        returns (address _owner, int256 amount, uint256 limitPrice)
    {
        require(orderId < orders.length, "Non existent order");
        _owner = orders[orderId].owner;
        amount = orders[orderId].amount;
        limitPrice = orders[orderId].limitPrice;
    }

    function cancelOrder(uint256 orderId) internal {
        orders[orderId].amount = 0;
    }

    function cancel(uint256 orderId) external {
        require(orderId < orders.length, "Non exsitent order");
        require(msg.sender == orders[orderId].owner, "Unauthorized");
        if (orders[orderId].amount != 0) numActiveOrders--; // Dust orders count as not canceled
        cancelOrder(orderId);
    }

    function withdrawFees(
        address payTo
    ) external onlyOwner returns (uint256 collected) {
        safeTransfer(settlementCurrency, payTo, feesToCollect);
        collected = feesToCollect;
        feesToCollect = 0;
    }

    function flashCollateralizeAndExecute(uint256 desiredCollateral) external {
        // Award desired collateral
        uint256 myPositionId = positionIds[msg.sender];
        if (myPositionId == 0) {
            // No position
            // Create position
            myPositionId = positions.length;
            positions.push();
            positionIds[msg.sender] = myPositionId;
            positions[myPositionId].owner = msg.sender;
        }
        positions[myPositionId].collateral += int256(desiredCollateral);

        // Call back the beneficiary
        IFlashCollateralBeneficiary(msg.sender).callBack();

        // Now take the awarded collateral back
        require(
            positions[myPositionId].collateral >= int256(desiredCollateral),
            "Cannot repay awarded collateral"
        );
        positions[myPositionId].collateral -= int256(desiredCollateral); // Repay awarded collateral

        // Check collateralization
        require(
            positions[myPositionId].collateral >=
                getRequiredEntryCollateral(myPositionId, getPrice()),
            "Undercollateralized"
        );
    }
}
