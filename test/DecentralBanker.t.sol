// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {DecentralBanker} from "../src/DecentralBanker.sol";
import {MockUSDC} from "../src/MockUSDC.sol";

/// @notice Stand-in for a DEX router: one function that fills, one that fails.
contract MockDEX {
    event Filled(address indexed from, uint256 amount);

    function fill(uint256 amount) external payable {
        emit Filled(msg.sender, amount);
    }

    function alwaysReverts() external pure {
        revert("dex: no fill");
    }
}

contract DecentralBankerTest is Test {
    MockUSDC internal usdc;
    MockDEX internal dex;
    DecentralBanker internal banker;

    address internal owner = makeAddr("owner");
    address internal operator = makeAddr("operator");
    address internal cexDeposit = makeAddr("cex-deposit");
    address internal attacker = makeAddr("attacker");

    function setUp() public {
        usdc = new MockUSDC();
        dex = new MockDEX();
        banker = new DecentralBanker(owner, operator);

        // Fund the desk.
        usdc.mint(address(banker), 100_000e6);
        vm.deal(address(banker), 10 ether);

        // Cold owner whitelists the trading accounts.
        vm.startPrank(owner);
        banker.allowDestination(cexDeposit);
        banker.allowDestination(address(dex));
        banker.allowDestination(address(usdc));
        vm.stopPrank();
    }

    function testSweepToCexDeposit() public {
        vm.prank(operator);
        banker.sweep(usdc, cexDeposit, 25_000e6);

        assertEq(usdc.balanceOf(cexDeposit), 25_000e6);
        assertEq(usdc.balanceOf(address(banker)), 75_000e6);
    }

    function testSweepBlockedToUnknownAddress() public {
        vm.prank(operator);
        vm.expectRevert(abi.encodeWithSelector(DecentralBanker.DestinationNotAllowed.selector, attacker));
        banker.sweep(usdc, attacker, 1_000e6);
    }

    function testExecuteDexLeg() public {
        DecentralBanker.Leg memory leg =
            DecentralBanker.Leg({target: address(dex), value: 1 ether, data: abi.encodeCall(MockDEX.fill, (500))});

        vm.prank(operator);
        banker.execute(leg);

        assertEq(address(dex).balance, 1 ether);
        assertEq(banker.nonce(), 1);
    }

    function testBatchSettlesAtomically() public {
        // Leg 1 is valid, leg 2 always fails: the whole route must revert.
        DecentralBanker.Leg[] memory legs = new DecentralBanker.Leg[](2);
        legs[0] = DecentralBanker.Leg({
            target: address(usdc),
            value: 0,
            data: abi.encodeCall(usdc.transfer, (cexDeposit, 10_000e6))
        });
        legs[1] = DecentralBanker.Leg({
            target: address(dex),
            value: 0,
            data: abi.encodeCall(MockDEX.alwaysReverts, ())
        });

        vm.prank(operator);
        vm.expectRevert(abi.encodeWithSelector(DecentralBanker.CallFailed.selector, address(dex)));
        banker.executeBatch(legs);

        // First leg rolled back: nothing moved.
        assertEq(usdc.balanceOf(cexDeposit), 0);
        assertEq(usdc.balanceOf(address(banker)), 100_000e6);
    }

    function testBatchOfValidLegsMovesEverything() public {
        DecentralBanker.Leg[] memory legs = new DecentralBanker.Leg[](2);
        legs[0] = DecentralBanker.Leg({
            target: address(usdc),
            value: 0,
            data: abi.encodeCall(usdc.transfer, (cexDeposit, 10_000e6))
        });
        legs[1] = DecentralBanker.Leg({target: address(dex), value: 0.5 ether, data: abi.encodeCall(MockDEX.fill, (7))});

        vm.prank(operator);
        banker.executeBatch(legs);

        assertEq(usdc.balanceOf(cexDeposit), 10_000e6);
        assertEq(address(dex).balance, 0.5 ether);
        assertEq(banker.nonce(), 1);
    }

    function testStrangerCannotMoveFunds() public {
        vm.startPrank(attacker);
        vm.expectRevert(DecentralBanker.NotAuthorized.selector);
        banker.sweep(usdc, cexDeposit, 1);
        vm.expectRevert(DecentralBanker.NotAuthorized.selector);
        banker.execute(DecentralBanker.Leg({target: cexDeposit, value: 0, data: ""}));
        vm.stopPrank();
    }

    function testOnlyOwnerManagesWhitelist() public {
        vm.prank(operator);
        vm.expectRevert();
        banker.allowDestination(attacker);

        vm.prank(owner);
        banker.allowDestination(attacker);
        assertTrue(banker.isAllowed(attacker));

        vm.prank(owner);
        banker.blockDestination(attacker);
        assertFalse(banker.isAllowed(attacker));
    }

    function testPauseFreezesAllFlows() public {
        vm.prank(owner);
        banker.pause();

        vm.startPrank(operator);
        vm.expectRevert();
        banker.sweep(usdc, cexDeposit, 1);
        vm.expectRevert();
        banker.execute(DecentralBanker.Leg({target: cexDeposit, value: 0, data: ""}));
        vm.stopPrank();

        vm.prank(owner);
        banker.unpause();

        vm.prank(operator);
        banker.sweep(usdc, cexDeposit, 1_000e6);
        assertEq(usdc.balanceOf(cexDeposit), 1_000e6);
    }

    function testOperatorRotation() public {
        address next = makeAddr("operator-next");
        vm.prank(owner);
        banker.setOperator(next);

        vm.prank(operator);
        vm.expectRevert(DecentralBanker.NotAuthorized.selector);
        banker.sweep(usdc, cexDeposit, 1);

        vm.prank(next);
        banker.sweep(usdc, cexDeposit, 1_000e6);
        assertEq(usdc.balanceOf(cexDeposit), 1_000e6);
    }

    function testOwnerCanAlwaysOperate() public {
        vm.prank(owner);
        banker.sweep(usdc, cexDeposit, 2_000e6);
        assertEq(usdc.balanceOf(cexDeposit), 2_000e6);
    }

    function testSweepETH() public {
        vm.prank(operator);
        banker.sweepETH(cexDeposit, 3 ether);
        assertEq(cexDeposit.balance, 3 ether);
    }

    function testReceivesETH() public {
        (bool ok,) = address(banker).call{value: 1 ether}("");
        assertTrue(ok);
        assertEq(address(banker).balance, 11 ether);
    }
}
