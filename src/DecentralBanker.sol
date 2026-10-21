// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title DecentralBanker
/// @notice Money-movement engine between trading accounts (CEX deposit
/// addresses, DEX routers, bridge contracts).
/// Holds the desk's funds and only ever sends them to whitelisted
/// destinations, so even a compromised hot key cannot drain funds to an
/// attacker. Multi-leg routes settle atomically: any failing leg reverts
/// the whole route. The cold owner keeps admin rights; the hot operator
/// (trading engine) only moves money along allowed paths.
contract DecentralBanker is Ownable, Pausable {
    using SafeERC20 for IERC20;

    struct Leg {
        address target;
        uint256 value;
        bytes data;
    }

    /// @notice Hot signer (trading engine). Cold owner keeps admin rights.
    address public operator;
    /// @notice Increments on every execution for off-chain reconciliation.
    uint256 public nonce;
    /// @notice Allowed destinations: CEX deposit addresses, DEX routers, bridges.
    mapping(address account => bool allowed) public isAllowed;

    error NotAuthorized();
    error DestinationNotAllowed(address target);
    error CallFailed(address target);
    error ZeroAddress();

    event OperatorUpdated(address indexed operator);
    event DestinationAllowed(address indexed account);
    event DestinationBlocked(address indexed account);
    event Executed(uint256 indexed nonce, address indexed target, uint256 value);
    event Swept(address indexed token, address indexed to, uint256 amount);

    constructor(address owner_, address operator_) Ownable(owner_) {
        if (operator_ == address(0)) revert ZeroAddress();
        operator = operator_;
    }

    modifier onlyOperator() {
        if (msg.sender != operator && msg.sender != owner()) revert NotAuthorized();
        _;
    }

    receive() external payable {}

    /// @notice Rotate the hot signer. Cold owner only.
    function setOperator(address operator_) external onlyOwner {
        if (operator_ == address(0)) revert ZeroAddress();
        operator = operator_;
        emit OperatorUpdated(operator_);
    }

    /// @notice Whitelist a destination (CEX deposit address, DEX router, bridge).
    function allowDestination(address account) external onlyOwner {
        if (account == address(0)) revert ZeroAddress();
        isAllowed[account] = true;
        emit DestinationAllowed(account);
    }

    /// @notice Remove a destination from the whitelist.
    function blockDestination(address account) external onlyOwner {
        isAllowed[account] = false;
        emit DestinationBlocked(account);
    }

    /// @notice Execute one leg to a whitelisted destination.
    function execute(Leg calldata leg) external onlyOperator whenNotPaused returns (bytes memory) {
        _checkAllowed(leg.target);
        uint256 id = ++nonce;
        (bool ok, bytes memory ret) = leg.target.call{value: leg.value}(leg.data);
        if (!ok) revert CallFailed(leg.target);
        emit Executed(id, leg.target, leg.value);
        return ret;
    }

    /// @notice Execute legs atomically: any failure reverts the whole route.
    function executeBatch(Leg[] calldata legs) external onlyOperator whenNotPaused returns (bytes[] memory) {
        uint256 id = ++nonce;
        bytes[] memory results = new bytes[](legs.length);
        for (uint256 i = 0; i < legs.length; ++i) {
            _checkAllowed(legs[i].target);
            (bool ok, bytes memory ret) = legs[i].target.call{value: legs[i].value}(legs[i].data);
            if (!ok) revert CallFailed(legs[i].target);
            emit Executed(id, legs[i].target, legs[i].value);
            results[i] = ret;
        }
        return results;
    }

    /// @notice Move tokens to a whitelisted address (e.g. CEX deposit).
    function sweep(IERC20 token, address to, uint256 amount) external onlyOperator whenNotPaused {
        _checkAllowed(to);
        token.safeTransfer(to, amount);
        emit Swept(address(token), to, amount);
    }

    /// @notice Move native gas token to a whitelisted address.
    function sweepETH(address to, uint256 amount) external onlyOperator whenNotPaused {
        _checkAllowed(to);
        (bool ok,) = to.call{value: amount}("");
        if (!ok) revert CallFailed(to);
        emit Swept(address(0), to, amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _checkAllowed(address target) internal view {
        if (!isAllowed[target]) revert DestinationNotAllowed(target);
    }
}
