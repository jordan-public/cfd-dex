// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/CFDOrderBook.sol";
import "../src/CFDOrderBookFactory.sol";
import "../src/ERC20.sol";
import "../src/MockPriceFeedOracle.sol";
import "../src/FlashLiquidate.sol";

contract Deploy is Script {
    uint256 ENTRY_MARGIN =          100000000000000000; // 0.1 = 10% (18 decimals)
    uint256 MAINTENANCE_MARGIN =     50000000000000000; // 0.05 = 5% (18 decimals)
    uint256 LIQUIDATION_PENALTY =    20000000000000000; // 0.02 = 2% (18 decimals)
    uint256 DUST =                   10000000000000000; // 0.01 (18 decimals)
        
    function run() external {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(); /*deployerPrivateKey*/

        console.log("Creator (owner): ", msg.sender);

        // Mock (test) USD compatible token
        IERC20 MUSD = new ERC20("Mock USD", "MUSD", 6, 0);
        // BTW, anyone can call MUSD.mint(wish) to mint "wish" amount of Mock USD for testing.
        console.log("Mock USD address: ", address(MUSD));

        MockPriceFeedOracle MOCK_ORACLE_CNY_USD = new MockPriceFeedOracle();
        console.log("MockPriceFeedOracle deployed: ", address(MOCK_ORACLE_CNY_USD));

        CFDOrderBookFactory factory = new CFDOrderBookFactory();
        console.log(
            "CFD Order Book Factory deployed: ",
            address(factory)
        );

        {
            factory.createOrderBook(address(MOCK_ORACLE_CNY_USD), address(MUSD), ENTRY_MARGIN, MAINTENANCE_MARGIN, LIQUIDATION_PENALTY, DUST);
            ICFDOrderBook p = factory.getOB(factory.getNumOBs() - 1); // Assuning no one runs this script concurrently
            console.log("CFD Order Book", p.getDescription(), "deployed at:", address(p));

            IFlashCollateralBeneficiary l = new FlashLiquidate(address(p));
            console.log("Flash Liquidation for", p.getDescription(), "deployed at:", address(l)); 
        }
    }
}
