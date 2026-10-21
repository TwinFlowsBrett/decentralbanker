# DecentralBanker

The money-movement brain for a trading operation. One contract holds the
desk's funds and routes them between accounts — exchange deposit addresses,
onchain venues, eventually bridges. Money only ever flows to pre-approved
addresses, and multi-step routes settle atomically or not at all.

Start here:

- Product story: [docs/PRODUCT.md](docs/PRODUCT.md)
- How the contracts work: [docs/CONTRACTS.md](docs/CONTRACTS.md)
- Funding plan: [docs/ARBITRUM_FUNDING_PACK.md](docs/ARBITRUM_FUNDING_PACK.md)

Live on Arbitrum Sepolia:
[0x68Fe76e555a13323b96963014Af332041b4c4eEA](https://sepolia.arbiscan.io/address/0x68Fe76e555a13323b96963014Af332041b4c4eEA)

## For builders

Contracts (Foundry, Solidity 0.8.24):

- `src/DecentralBanker.sol` — the flow engine (whitelist, atomic batches).
- `src/MockUSDC.sol` — play money for testing and demos only.

```sh
forge build
forge test
```

## Deploy

```sh
PRIVATE_KEY=0x... \
OWNER=0x... \
OPERATOR=0x... \
forge script script/Deploy.s.sol \
  --rpc-url https://sepolia-rollup.arbitrum.io/rpc --broadcast
```

`OWNER` = cold admin. `OPERATOR` = hot trading-engine key. Both default to
the deployer; rotate the operator to a dedicated hot key before real use.

## Roadmap

1. Flow engine (this repo) + testnet demo.
2. Per-destination limits and daily caps.
3. Built-in bridging through approved bridge contracts.
4. Audit, guarded mainnet launch.
