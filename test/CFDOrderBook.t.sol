// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/CFDOrderBook.sol";
import "../src/CFDOrderBookFactory.sol";
import "../src/FlashLiquidate.sol";
import "../src/ERC20.sol";

contract CFDOrderBookTest is Test {
    // Gnosis Mainnet
    // address constant USDC = 0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83;
    
    address constant ORACLE_EUR_USD =
        0xab70BCB260073d036d1660201e9d5405F5829b7a;
    address constant ORACLE_CHF_USD =
        0xFb00261Af80ADb1629D3869E377ae1EEC7bE659F;
    address constant ORACLE_JPY_USD =
        0x2AfB993C670C01e9dA1550c58e8039C1D8b8A317;
    address constant ORACLE_MXN_USD =
        0xe9cea51a7b1b9B32E057ff62762a2066dA933cD2;
    
    uint256 ENTRY_MARGIN =          100000000000000000; // 0.1 = 10%
    uint256 MAINTENANCE_MARGIN =     50000000000000000; // 0.05 = 5%
    uint256 LIQUIDATION_PENALTY =    20000000000000000; // 0.02 = 2%
    uint256 DUST =                   10000; // 0.01 (6 decimals)
    
    // Test accounts from passphrase in env (not in repo)
    address constant account0 = 0x17eE56D300E3A0a6d5Fd9D56197bFfE968096EdB;
    address constant account1 = 0xFE6A93054b240b2979F57e49118A514F75f66D4e;
    address constant account2 = 0xcEeEa627dDe5EF73Fe8625e146EeBba0fdEB00bd;
    address constant account3 = 0xEf5b07C0cb002853AdaD2B2E817e5C66b62d34E6;
    address constant account4 = 0x895652cB06D430D45662291b394253FF97dD8B9E;

    IERC20 USDC;
    ICFDOrderBookFactory factory;
    CFDOrderBook ob;
    ICFDOrderBook obi;
    FlashLiquidate flashLiquidate;

    function setUp() public {
        console.log("Creator (owner): ", msg.sender);

        // Test USDC token
        USDC = new ERC20("Test USDC", "USDC", 6, 10**6 * 10**6); // 1M total supply
        console.log("Test USDC address: ", address(USDC));
        USDC.transfer(account1, 200000 * 10**USDC.decimals());
        USDC.transfer(account2, 100000 * 10**USDC.decimals());
        USDC.transfer(account3, 100000 * 10**USDC.decimals());

        factory = new CFDOrderBookFactory();
        console.log(
            "CFD Order Book Factory deployed: ",
            address(factory)
        );
        console.log("Factory owner: ", factory.owner());

        {
            factory.createOrderBook(ORACLE_EUR_USD, address(USDC), ENTRY_MARGIN, MAINTENANCE_MARGIN, LIQUIDATION_PENALTY, DUST);
            ICFDOrderBook p = factory.getOB(factory.getNumOBs() - 1); // Assuning no one runs this script concurrently
            console.log("CFD Order Book", p.getDescription(), "deployed at:", address(p));
        }

        obi = factory.getOB(factory.getNumOBs() - 1);
        ob = CFDOrderBook(address(obi));

        flashLiquidate = new FlashLiquidate(address(obi));
        console.log("FlashLiquidate on ", flashLiquidate.cfdOrderBook().getDescription(), "deployed at:", address(flashLiquidate));
    }

    function testDepositWithdraw() public {
        uint256 amount = 10 * 10**USDC.decimals();
        USDC.approve(address(ob), amount);
        ob.deposit(amount);
        ob.withdraw(amount);

        USDC.approve(address(ob), amount);
        ob.deposit(amount);
        assertEq(amount, ob.withdrawMax(), "withdrawMax amount mismatch");
    }

    function testBidOffer() public {
        uint256 amount = 100 * 10**USDC.decimals();
        USDC.approve(address(ob), amount);
        ob.deposit(amount);
        uint256 price = ob.getPrice();
        uint256 pdenom = ob.priceDenominator();
        ob.make(int256(((amount * pdenom) / price) / 3), price * 9999 / 10000); // Bid
        ob.make(- int256(((amount * pdenom) / price) / 3), price * 10001 / 10000); // Offer
    }

    function testFlashTrillionCollateral() public {
        // Owner sets mock oracle price of EUR/USD ro 1.1
        vm.startPrank(factory.owner(), factory.owner());
        obi.setMockPrice(110000000);
        vm.stopPrank();

        // account1 deposits 100K USDC and makes bid for 800K EUR/USD @ 1.1
        vm.startPrank(account1, account1);
        USDC.approve(address(obi), type(uint256).max);
        obi.deposit(100000 * 10**USDC.decimals());
        uint256 bidOrderId = obi.make(800000 * 10**18, 110000000);
        vm.stopPrank();

        // account2 deposits 100K USDC and takes the above order
        vm.startPrank(account2, account2);
        USDC.approve(address(obi), type(uint256).max);
        obi.deposit(100000 * 10**USDC.decimals());
        obi.take(bidOrderId, -800000 * 10**18);
        vm.stopPrank();
        // Now account2 owns -800K EUR/USD @ 1.1 (short position), 
        // which requires entry (10%) collateral of 88K

        // Owner sets mock oracle price of EUR/USD ro 1.2
        vm.startPrank(factory.owner(), factory.owner());
        obi.setMockPrice(120000000);
        vm.stopPrank();
        // At this time account2 owning 800K @1.1,
        // so at the current price of 1.2, the unrealized loss is 80K USD.
        // Required maintenance collateral of 5% (of 800K * 1.2) is
        // 47K USD, but the actual collateral is depleted by the 
        // unrealized loss 100K - 80K = 20K. The account can beliquidated.

        // account3 deposits 100K of collateral and places an offer for 800K EUR/USD @1.21
        vm.startPrank(account3, account3);
        USDC.approve(address(obi), type(uint256).max);
        obi.deposit(100000 * 10**USDC.decimals());
        uint256 offerOrderId = obi.make(-800000 * 10**18, 12100000);
        vm.stopPrank();

        // At this time account4, which has no USDC will
        // liquidate account2 and assume its position @1.2
        // and immediately cover the short by taking the offer
        // from account3 at 1.21, taking a loss of 0.01 * 800K = 8K.
        // But the liquidation will result in collection of 2% penalty,
        // which is 2% * 800K * 1.2 = 9600 USD. The liquidator will
        // make a profit of $1600 less the protocol fees,
        // without investing any money.
        vm.startPrank(account4, account4);
        uint256 had = USDC.balanceOf(account4);
        uint256 positionToLiquidate = obi.positionIds(account2); // This can be searched, but for the example we know it belongs to account2
        uint256 TRILLION = 10**12 * 10**USDC.decimals();
        uint256[] memory p = new uint256[](1); p[0] = positionToLiquidate;
        uint256[] memory o = new uint256[](1); o[0] = offerOrderId;
        int256[] memory a = new int256[](1); a[0] = int256(800000 * 10**18);
        flashLiquidate.liquidate(TRILLION, p, o, a); // Flash liquidation
        uint256 has = USDC.balanceOf(account4);
        console.log("Profit", has-had);
        vm.stopPrank();
    }

    function testBadCall() public {
        // Put test to be debugged here
        return;
    }

}
