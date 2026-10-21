// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DecentralVault} from "../src/DecentralVault.sol";
import {MockUSDC} from "../src/MockUSDC.sol";

/// @notice Deploy The Decentral Bank vault.
/// - If USDC_ADDRESS is set, the vault points at it (Arbitrum One / Sepolia native USDC).
/// - Otherwise a MockUSDC is deployed (local Anvil demos).
/// Env: PRIVATE_KEY, [USDC_ADDRESS], [DEPOSIT_CAP], [OWNER]
contract Deploy is Script {
    function run() public {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address usdcAddress = vm.envOr("USDC_ADDRESS", address(0));
        uint256 depositCap = vm.envOr("DEPOSIT_CAP", uint256(1_000_000e6));
        address deployer = vm.addr(deployerKey);
        address owner = vm.envOr("OWNER", deployer);

        vm.startBroadcast(deployerKey);

        IERC20 asset;
        if (usdcAddress == address(0)) {
            MockUSDC mock = new MockUSDC();
            asset = IERC20(address(mock));
            console.log("MockUSDC deployed:", address(mock));
        } else {
            asset = IERC20(usdcAddress);
            console.log("Using USDC:", usdcAddress);
        }

        DecentralVault vault =
            new DecentralVault(asset, "Decentral USD", "dUSD", depositCap, owner);
        console.log("DecentralVault deployed:", address(vault));

        vm.stopBroadcast();
    }
}
