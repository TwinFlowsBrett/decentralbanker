# Arbitrum Funding Pack — The Decentral Bank

Status snapshot: October 2026. Verified against https://arbitrum.foundation/grants.

## Program status

| Program | Status | Fit | Action |
|---|---|---|---|
| Foundation Grant Program | Inactive (complete) | Highest | Have proposal ready for reopen |
| DAO Grant Program | Inactive | High | Watch DAO forum |
| Stablecoin Growth Program | Active | Highest | Apply once USDG-ready |
| Security Program (audits) | Active | High | Apply pre-mainnet |
| ArbiFuel (gas sponsorship) | Active | High | Apply now |
| Alchemy Orbit ($10M credits) | Active | Low | Only if Orbit route |

## 1. ArbiFuel — apply now

Gas sponsorship for early-stage teams. No TVL requirement.

- Apply: https://airtable.com/appzb4GfqGfrnDXjW/shrulGIIp6l6ezAlt
- Project: DecentralBanker — money-movement engine routing desk funds
  between exchange accounts and onchain venues through whitelisted,
  atomic-settling routes on Arbitrum.
- Use of funds: Sepolia + mainnet deployment gas, route testing against
  Arbitrum venues, demo flows for partners.
- Milestone: engine live on Arbitrum Sepolia with public demo (done, see repo).
- Links: [REPO_URL], demo address after Sepolia deploy.

## 2. Security Program — apply before mainnet

12-month program, third-party audit subsidies for high-potential projects.

- Apply: https://tally.so/r/3xzEzv?program=asp&ref=arbitrum.foundation
- Scope: DecentralBanker.sol (whitelisted destinations, atomic batch
  routes, hot/cold key split, pause).
- Status: 12/12 Foundry tests passing, OZ v5 dependencies. Audit is the
  gating item before guarded mainnet launch.
- Ask: subsidy for one audit contest or firm review.

## 3. Stablecoin Growth Program — apply when USDG-ready

For protocols making USDG their primary stablecoin. Requires $1M+ stablecoin
balances; 2M ARB prize pool for first 10 teams to $10M USDG TVL.

- Apply: https://airtable.com/appNPlINVhkcwnyaZ/shrHJBg8jQdc3sJEa
- Strategy: route stablecoin flows through USDG as the primary settlement
  asset so desk volume qualifies as USDG TVL. This is the largest active
  pool of ARB available to a flow-shaped project — prioritize in the roadmap.

## 4. General grant proposal (ready for reopen)

Target: Arbitrum Foundation Grant Program ($10K–$250K range when active).

**Ask: $50,000 in ARB, milestone-based.**

- Project: DecentralBanker — white-label money-movement engine for trading
  desks on Arbitrum. Whitelisted CEX/DEX routing with atomic settlement
  today; per-destination limits and built-in bridging next.
- Why Arbitrum: deepest L2 venue liquidity (~$9B+ TVL), low-latency
  execution, EVM composability with venue and bridge contracts, active
  stablecoin incentive programs.

Milestones:

1. $10K — Sepolia engine live, public demo of routed flows, docs.
2. $20K — Audit complete (via Security Program), guarded mainnet launch,
   Dune dashboard of routed volume.
3. $20K — Per-destination limits live, USDG settlement flows, Stablecoin
   Growth Program application submitted, one bridge adapter shipped.

Team: [NAMES, BACKGROUNDS, GITHUB/TWITTER].
Contact: [EMAIL].
Repo: https://github.com/TwinFlowsBrett/decentralbanker.
