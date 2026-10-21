// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {DecentralVault} from "../src/DecentralVault.sol";
import {MockUSDC} from "../src/MockUSDC.sol";

contract DecentralVaultTest is Test {
    MockUSDC internal usdc;
    DecentralVault internal vault;
    address internal alice = makeAddr("alice");
    address internal bank = makeAddr("bank");

    uint256 internal constant CAP = 1_000_000e6;

    function setUp() public {
        usdc = new MockUSDC();
        vault = new DecentralVault(usdc, "Decentral USD", "dUSD", CAP, bank);
        usdc.mint(alice, 100_000e6);
        usdc.mint(bank, 100_000e6);
    }

    function testDepositMintsShares() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 10_000e6);
        uint256 shares = vault.deposit(10_000e6, alice);
        vm.stopPrank();

        assertEq(shares, 10_000e6, "1:1 on first deposit");
        assertEq(vault.balanceOf(alice), shares);
        assertEq(vault.totalAssets(), 10_000e6);
    }

    function testWithdrawReturnsAssets() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 10_000e6);
        vault.deposit(10_000e6, alice);
        vault.withdraw(4_000e6, alice, alice);
        vm.stopPrank();

        assertEq(usdc.balanceOf(alice), 94_000e6);
        assertEq(vault.totalAssets(), 6_000e6);
    }

    function testYieldDonationRaisesSharePrice() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 10_000e6);
        vault.deposit(10_000e6, alice);
        vm.stopPrank();

        vm.startPrank(bank);
        usdc.approve(address(vault), 1_000e6);
        vault.donateYield(1_000e6);
        vm.stopPrank();

        // 10,000 shares now backed by 11,000 assets => ~1.1 assets per share.
        // OZ's virtual-share offset rounds 1 micro-unit in the vault's favor.
        assertApproxEqAbs(vault.convertToAssets(10_000e6), 11_000e6, 2);

        vm.prank(alice);
        uint256 redeemed = vault.redeem(10_000e6, alice, alice);
        assertApproxEqAbs(redeemed, 11_000e6, 2, "alice captures the donated yield");
    }

    function testDepositCapEnforced() public {
        assertEq(vault.maxDeposit(alice), CAP);

        vm.startPrank(alice);
        usdc.approve(address(vault), 100_000e6);
        vm.expectRevert();
        vault.deposit(CAP + 1, alice);
        vm.stopPrank();
    }

    function testMaxDepositTracksRemainingCap() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 100_000e6);
        vault.deposit(100_000e6, alice);
        vm.stopPrank();

        assertEq(vault.maxDeposit(alice), CAP - 100_000e6);
    }

    function testPauseBlocksDepositsAndWithdrawals() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 10_000e6);
        vault.deposit(10_000e6, alice);
        vm.stopPrank();

        vm.prank(bank);
        vault.pause();

        assertEq(vault.maxDeposit(alice), 0);

        vm.startPrank(alice);
        usdc.approve(address(vault), 1_000e6);
        vm.expectRevert();
        vault.deposit(1_000e6, alice);
        vm.expectRevert();
        vault.withdraw(1_000e6, alice, alice);
        vm.stopPrank();

        vm.prank(bank);
        vault.unpause();

        vm.prank(alice);
        vault.withdraw(1_000e6, alice, alice);
        assertEq(vault.totalAssets(), 9_000e6);
    }

    function testOnlyOwnerCanSetCap() public {
        vm.prank(alice);
        vm.expectRevert();
        vault.setDepositCap(0);

        vm.prank(bank);
        vault.setDepositCap(0);
        assertEq(vault.depositCap(), 0);
    }
}
