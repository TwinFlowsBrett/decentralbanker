// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DecentralBanker} from "../src/DecentralBanker.sol";

/// @notice Deploy the DecentralBanker flow engine.
/// Env: PRIVATE_KEY, [OWNER], [OPERATOR].
/// OWNER = cold admin (whitelist, pause). OPERATOR = hot trading-engine signer.
contract Deploy is Script {
    function run() public {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        address owner = vm.envOr("OWNER", deployer);
        address operator = vm.envOr("OPERATOR", deployer);

        vm.startBroadcast(deployerKey);
        DecentralBanker banker = new DecentralBanker(owner, operator);
        console.log("DecentralBanker deployed:", address(banker));
        console.log("owner:", owner);
        console.log("operator:", operator);
        vm.stopBroadcast();
    }
}
