// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/CFDOrderBook.sol";
import "../src/CFDOrderBookFactory.sol";

contract Deploy is Script {
    // Gnosis Mainnet
    address constant USDC = 0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83;
    
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
    
    function run() external {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(); /*deployerPrivateKey*/

        console.log("Creator (owner): ", msg.sender);
  
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
