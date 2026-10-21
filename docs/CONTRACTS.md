# DecentralBanker — How the Contracts Work

Plain-language guide to the code in `src/`. For the product story, see
[PRODUCT.md](PRODUCT.md).

## The big picture

| Contract | Plain meaning |
|---|---|
| DecentralBanker | The money-movement engine |
| MockUSDC | Play money for testing |

The engine holds the desk's funds. The cold owner decides which addresses
are approved. The hot operator (trading engine) moves money between them.

## DecentralBanker — the engine

File: `src/DecentralBanker.sol`

### The two keys

- **Owner (cold).** Manages the approved-address list, rotates the operator,
  owns the emergency stop. Can always move funds itself.
- **Operator (hot).** The trading engine's key. Can move funds, but only to
  approved addresses. Cannot change the list or the rules.

### The approved-address list

- `allowDestination(account)` — approve an account: an exchange deposit
  address, an onchain venue router, a bridge contract. Owner only.
- `blockDestination(account)` — remove one. Owner only.
- `isAllowed(account)` — check whether an account is approved.

### Moving money

- `sweep(token, to, amount)` — send tokens to an approved account. The
  everyday "push profits to the exchange" call.
- `sweepETH(to, amount)` — same for the native gas token.
- `execute(leg)` — one custom step: call an approved contract with data and
  optional value. Used for venue interactions (deposits, fills).
- `executeBatch(legs)` — run several steps as one atomic route. If any step
  fails or hits an unapproved address, everything reverts and nothing moves.
- `receive()` — the engine accepts plain transfers in from anywhere.

### Tracking

- `nonce` — counts up on every execution. The off-chain books match each
  movement against this exact sequence.
- Events `Executed` and `Swept` — the permanent public log of where every
  unit went, with the nonce attached.

### Emergency stop

- `pause()` / `unpause()` — freezes all movement. Owner only.

### What can go wrong

| Attack | What happens |
|---|---|
| Hot key stolen | Attacker can only move funds between your approved accounts |
| Rogue destination added | Only the cold owner can approve addresses |
| Route step fails mid-way | Whole batch reverts, funds stay put |
| Exchange deposit address changes | Owner blocks the old one, approves the new one |

## MockUSDC — play money

File: `src/MockUSDC.sol`

A fake dollar for local testing and testnet demos: 6 decimals like real USDC,
with an open `mint` anyone can call. Live deployments move real assets; the
engine itself never touches MockUSDC.

## Deploying

File: `script/Deploy.s.sol`

- `OWNER` sets the cold admin (defaults to the deployer).
- `OPERATOR` sets the hot trading-engine key (defaults to the deployer —
  rotate to a dedicated hot key before real use).

## Testing

File: `test/DecentralBanker.t.sol` — 12 tests, all passing:

- Sweeps reach the approved exchange address; unknown addresses revert.
- Single venue legs execute and bump the sequence number.
- Batches with a failing step revert entirely — nothing moves.
- Batches of valid steps move everything in one go.
- Strangers cannot move funds; only the owner manages the list.
- Pausing freezes all flows; unpausing restores them.
- Operator rotation revokes the old key and activates the new one.
- The owner can always operate; ETH sweeps and plain ETH intake work.

Run: `forge build`, then `forge test`.

## Live addresses

| Network | Engine |
|---|---|
| Arbitrum Sepolia | 0x68Fe76e555a13323b96963014Af332041b4c4eEA |
| Arbitrum One | Not yet deployed |

View on Arbiscan Sepolia: https://sepolia.arbiscan.io/address/0x68Fe76e555a13323b96963014Af332041b4c4eEA

(The earlier savings-vault demo was superseded by this pivot and is no
longer maintained.)

## Security status

- Built on OpenZeppelin v5 audited components (ownership, pause).
- Token transfers use SafeERC20 (no silent failures).
- Custom errors instead of revert strings (cheaper, clearer).
- Professional audit is the gating item before mainnet — see the Arbitrum
  Security Program application in [ARBITRUM_FUNDING_PACK.md](ARBITRUM_FUNDING_PACK.md).
