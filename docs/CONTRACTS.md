# DecentralBanker — How the Contracts Work

Plain-language guide to the code in `src/`. For the product story, see
[PRODUCT.md](PRODUCT.md).

## The big picture

Two contracts do everything:

| Contract | Plain meaning |
|---|---|
| DecentralVault | The savings pool |
| MockUSDC | Play money for testing |

On a live network, the pool holds real USDC (digital dollars). In tests and
demos, it holds MockUSDC, which works the same way but is worthless.

## DecentralVault — the savings pool

File: `src/DecentralVault.sol`

The vault follows the ERC4626 savings-pool standard — the same standard used
by major onchain funds — so wallets, apps, and other software already know
how to talk to it.

### Putting money in

- `deposit(amount, you)` — you send USDC in, you get dUSD receipt tokens back.
- The very first depositor gets 1 receipt token per $1. After that, the
  exchange rate floats with the pool: receipt price = pool dollars / receipt
  tokens out there.

### Taking money out

- `withdraw(amount, you, you)` — burn receipt tokens, get USDC back.
- `redeem(receipts, you, you)` — same thing, but you name the receipt amount
  instead of the dollar amount.

### Where interest comes from

- `donateYield(amount)` — the operator pays interest into the pool. It does
  not create new receipt tokens, so every existing token becomes redeemable
  for a little more. That rising receipt price IS the interest.
- Interest can come from anywhere — lending revenue, partner fees, incentive
  programs — the pool does not care about the source.

### Guardrails

- **Deposit cap** (`depositCap`, `setDepositCap`) — maximum dollars the pool
  accepts. Set low at launch, raised as trust grows. Zero means uncapped.
- **Safety switch** (`pause` / `unpause`) — freezes deposits and withdrawals
  in an emergency. Only the owner can flip it.
- **Owner** (`Ownable`) — the operator account. Manages the cap and the
  safety switch, nothing else. It cannot touch depositor funds.

### What it reports

- `totalAssets` — dollars currently in the pool.
- `convertToAssets(receipts)` / `convertToShares(dollars)` — the live
  exchange rate, both directions.
- `maxDeposit(you)` — how much you can still put in (cap-aware).
- Events `DepositCapUpdated` and `YieldDonated` — a permanent public log of
  cap changes and interest payments.

### A note on rounding

Share math rounds down by design, at most a fraction of a cent, always in the
pool's favor. This is a standard protection against a known attack where
someone manipulates a nearly empty pool. Depositors never lose more than a
micro-cent per action.

## MockUSDC — play money

File: `src/MockUSDC.sol`

A fake dollar for local testing and testnet demos: 6 decimals like real USDC,
with an open `mint` anyone can call. It is never used with real money — live
deployments point the vault at native USDC instead.

## Deploying

File: `script/Deploy.s.sol`

One script for every network:

- No `USDC_ADDRESS` set → deploys MockUSDC plus a vault on top (local/demo).
- `USDC_ADDRESS` set → deploys a vault on the real stablecoin (live).
- `DEPOSIT_CAP` sets the launch limit (defaults to $1M). `OWNER` sets the
  operator (defaults to the deployer).

## Testing

File: `test/DecentralVault.t.sol` — 7 tests, all passing:

- Deposits mint the right receipt amount.
- Withdrawals return the right dollar amount.
- Paid interest raises the receipt price and reaches depositors.
- The deposit cap blocks over-cap deposits and reports remaining room.
- Pausing freezes deposits and withdrawals; unpausing restores them.
- Only the owner can change the cap.

Run: `forge build`, then `forge test`.

## Live addresses

| Network | Vault | Asset |
|---|---|---|
| Arbitrum Sepolia | TBD (deploy pending) | MockUSDC (pending) |
| Arbitrum One | Not yet deployed | — |

## Security status

- Built on OpenZeppelin v5 audited components.
- Token transfers use SafeERC20 (no silent failures).
- Professional audit is the gating item before mainnet — see the Arbitrum
  Security Program application in [ARBITRUM_FUNDING_PACK.md](ARBITRUM_FUNDING_PACK.md).
