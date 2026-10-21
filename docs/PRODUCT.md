# DecentralBanker — Product Overview

## What it is

DecentralBanker is the money-movement brain for a trading operation. One
contract holds the desk's funds and routes them between accounts —
centralized-exchange deposit addresses, onchain trading venues, and
eventually bridges to other networks. Money can only ever flow to
pre-approved addresses, and multi-step routes either settle completely or
not at all.

## The problem it solves

A desk with access to many venues faces two risks:

1. **A stolen hot key drains everything.** Trading engines need a key that
   can move fast — and that key is the juiciest target there is.
2. **Half-finished routes lose money.** A rebalance that completes step one
   but fails step two leaves funds stranded in the wrong place.

DecentralBanker answers both:

- **Approved addresses only.** The contract physically cannot send funds
  anywhere except whitelisted accounts. A compromised trading key can only
  move money between your own venues — never to an attacker.
- **Atomic routes.** Bundle every leg of a rebalance into one transaction.
  If any leg fails, the whole thing reverts and nothing moves.
- **Hot/cold split.** The trading engine gets a hot key that moves money
  along allowed paths. A cold key keeps the admin rights: editing the
  address list, rotating the hot key, hitting the emergency stop.

## How money flows

1. **In.** Funds arrive from anywhere — exchange withdrawals, trading
   profits, fresh capital.
2. **Through.** The trading engine fires single transfers or batched routes:
   sweep profits to the exchange deposit address, push inventory to the
   onchain venue, pull it back when done.
3. **Out — only to approved accounts.** Every destination on every transfer
   is checked against the whitelist. Unknown address, no deal.

Every movement emits an event with a sequence number, so the off-chain books
reconcile against an exact onchain log.

## Built for speed

- Tiny, gas-lean contract: one permission check, one whitelist check, then
  straight to execution. No accounting overhead in the hot path.
- Custom errors and calldata-only batching keep per-leg costs minimal.
- The sequence number lets the trading engine track fills without polling
  balances.

## Why it is white-label

Any trading firm, desk, or fund can run its own DecentralBanker — its own
accounts, its own address list, its own keys — on the same audited engine.
One codebase, many deployments, zero shared custody.

## The roadmap

1. Flow engine on Arbitrum (live in this repo).
2. Per-destination limits and daily caps.
3. Built-in bridging: approved bridge contracts become destinations, so
   cross-chain rebalances settle through the same atomic routes.
4. More networks, same engine.

## For builders

Technical guide: [CONTRACTS.md](CONTRACTS.md).
Run it locally: see the project [README](../README.md).
