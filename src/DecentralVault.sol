// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title DecentralVault
/// @notice ERC4626 savings vault for The Decentral Bank.
/// Depositors receive yield-bearing dToken shares backed 1:1+ by the
/// underlying asset (e.g. USDC on Arbitrum). The bank operator streams
/// yield into the vault via `donateYield`, raising the share price for
/// all depositors. Deposits can be capped during guarded launch.
contract DecentralVault is ERC4626, Ownable, Pausable {
    using SafeERC20 for IERC20;

    /// @notice Maximum assets the vault accepts. 0 = uncapped.
    uint256 public depositCap;

    event DepositCapUpdated(uint256 newCap);
    event YieldDonated(address indexed from, uint256 assets);

    constructor(
        IERC20 asset_,
        string memory name_,
        string memory symbol_,
        uint256 depositCap_,
        address owner_
    ) ERC4626(asset_) ERC20(name_, symbol_) Ownable(owner_) {
        depositCap = depositCap_;
    }

    /// @notice Total assets the vault will accept from `receiver`.
    function maxDeposit(address receiver) public view override returns (uint256) {
        if (paused()) return 0;
        uint256 assets = totalAssets();
        if (depositCap != 0 && assets >= depositCap) return 0;
        uint256 remaining = depositCap == 0 ? type(uint256).max : depositCap - assets;
        uint256 base = super.maxDeposit(receiver);
        return remaining < base ? remaining : base;
    }

    /// @notice Total shares the vault will mint for `receiver`.
    function maxMint(address receiver) public view override returns (uint256) {
        uint256 maxAssets = maxDeposit(receiver);
        if (maxAssets == type(uint256).max) return super.maxMint(receiver);
        return convertToShares(maxAssets);
    }

    /// @notice Stream yield into the vault, raising the share price for all holders.
    function donateYield(uint256 assets) external whenNotPaused {
        IERC20(asset()).safeTransferFrom(msg.sender, address(this), assets);
        emit YieldDonated(msg.sender, assets);
    }

    /// @notice Update the deposit cap. 0 = uncapped.
    function setDepositCap(uint256 newCap) external onlyOwner {
        depositCap = newCap;
        emit DepositCapUpdated(newCap);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _deposit(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares
    ) internal override whenNotPaused {
        super._deposit(caller, receiver, assets, shares);
    }

    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal override whenNotPaused {
        super._withdraw(caller, receiver, owner, assets, shares);
    }
}
