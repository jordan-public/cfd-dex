// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/CFDOrderBook.sol";
import "../src/CFDOrderBookFactory.sol";
//import "forge-std/interfaces/IERC20.sol";
import "../src/ERC20.sol";

contract Deploy is Script {
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
    uint256 DUST =                   10000000000000000; // 0.01
    
    // Test accounts from passphrase in env (not in repo)
    address constant account0 = 0x17eE56D300E3A0a6d5Fd9D56197bFfE968096EdB;
    address constant account1 = 0xFE6A93054b240b2979F57e49118A514F75f66D4e;
    address constant account2 = 0xcEeEa627dDe5EF73Fe8625e146EeBba0fdEB00bd;
    address constant account3 = 0xEf5b07C0cb002853AdaD2B2E817e5C66b62d34E6;

    function run() external {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(); /*deployerPrivateKey*/

        console.log("Creator (owner): ", msg.sender);

        // Test USDC token
        IERC20 USDC = new ERC20("Test USDC", "USDC", 6, 10**6 * 10**6); // 1M total supply
        console.log("Test USDC address: ", address(USDC));
        USDC.transfer(account1, 100000 * 10**USDC.decimals());
        USDC.transfer(account2, 100000 * 10**USDC.decimals());
        USDC.transfer(account3, 100000 * 10**USDC.decimals());

        CFDOrderBookFactory factory = new CFDOrderBookFactory();
        console.log(
            "CFD Order Book Factory deployed: ",
            address(factory)
        );

        {
            factory.createOrderBook(ORACLE_EUR_USD, address(USDC), ENTRY_MARGIN, MAINTENANCE_MARGIN, LIQUIDATION_PENALTY, DUST);
            ICFDOrderBook p = factory.getOB(factory.getNumOBs() - 1); // Assuning no one runs this script concurrently
            console.log("CFD Order Book", p.getDescription(), "deployed at:", address(p));
        }

        {
            factory.createOrderBook(ORACLE_CHF_USD, address(USDC), ENTRY_MARGIN, MAINTENANCE_MARGIN, LIQUIDATION_PENALTY, DUST);
            ICFDOrderBook p = factory.getOB(factory.getNumOBs() - 1); // Assuning no one runs this script concurrently
            console.log("CFD Order Book", p.getDescription(), "deployed at:", address(p));
        }

        {
            factory.createOrderBook(ORACLE_JPY_USD, address(USDC), ENTRY_MARGIN, MAINTENANCE_MARGIN, LIQUIDATION_PENALTY, DUST);
            ICFDOrderBook p = factory.getOB(factory.getNumOBs() - 1); // Assuning no one runs this script concurrently
            console.log("CFD Order Book", p.getDescription(), "deployed at:", address(p));
        }

        {
            factory.createOrderBook(ORACLE_MXN_USD, address(USDC), ENTRY_MARGIN, MAINTENANCE_MARGIN, LIQUIDATION_PENALTY, DUST);
            ICFDOrderBook p = factory.getOB(factory.getNumOBs() - 1); // Assuning no one runs this script concurrently
            console.log("CFD Order Book", p.getDescription(), "deployed at:", address(p));
        }
    }
}
