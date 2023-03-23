// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/CFDOrderBook.sol";
import "../src/CFDOrderBookFactory.sol";
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

    IERC20 USDC;
    CFDOrderBook ob;
    ICFDOrderBook obi;

    function setUp() public {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(); /*deployerPrivateKey*/

        console.log("Creator (owner): ", msg.sender);

        // Test USDC token
        USDC = new ERC20("Test USDC", "USDC", 6, 10**6 * 10**6); // 1M total supply
        console.log("Test USDC address: ", address(USDC));
        USDC.transfer(account1, 100000 * 10**USDC.decimals());
        USDC.transfer(account2, 100000 * 10**USDC.decimals());
        USDC.transfer(account3, 100000 * 10**USDC.decimals());

        ICFDOrderBookFactory factory = new CFDOrderBookFactory();
        console.log(
            "CFD Order Book Factory deployed: ",
            address(factory)
        );

        {
            factory.createOrderBook(ORACLE_EUR_USD, address(USDC), ENTRY_MARGIN, MAINTENANCE_MARGIN, LIQUIDATION_PENALTY, DUST);
            ICFDOrderBook p = factory.getOB(factory.getNumOBs() - 1); // Assuning no one runs this script concurrently
            console.log("CFD Order Book", p.getDescription(), "deployed at:", address(p));
        }

        obi = factory.getOB(factory.getNumOBs() - 1);
        ob = CFDOrderBook(address(obi));
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

    function testBadCall() public {
        uint256 amount = 100 * 10**USDC.decimals();
        USDC.approve(address(ob), amount);
        ob.deposit(amount);
        uint256 price = ob.getPrice();
        uint256 pdenom = ob.priceDenominator();
        ob.make(int256((((amount * pdenom) / price) * 10**18 / 10**USDC.decimals()) / 2), price);
    }

}
