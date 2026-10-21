# DecentralBanker

A savings account that lives on the internet instead of inside a bank.
Deposit digital dollars, earn interest, withdraw anytime. Built to be
white-labeled — any brand can launch its own savings product on these rails.

Start here:

- Product story: [docs/PRODUCT.md](docs/PRODUCT.md)
- How the contracts work: [docs/CONTRACTS.md](docs/CONTRACTS.md)
- Funding plan: [docs/ARBITRUM_FUNDING_PACK.md](docs/ARBITRUM_FUNDING_PACK.md)

## For builders

Contracts (Foundry, Solidity 0.8.24):

- `src/DecentralVault.sol` — the savings pool (ERC4626 standard).
- `src/MockUSDC.sol` — play money for testing and demos only.

```sh
forge build
forge test
```

## Deploy

Local (Anvil):

```sh
anvil  # separate terminal
PRIVATE_KEY=<anvil-key> forge script script/Deploy.s.sol \
  --rpc-url http://127.0.0.1:8545 --broadcast
```

Arbitrum Sepolia (deploys MockUSDC + vault):

```sh
export ARBITRUM_SEPOLIA_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
PRIVATE_KEY=0x... forge script script/Deploy.s.sol \
  --rpc-url $ARBITRUM_SEPOLIA_RPC_URL --broadcast --verify
```

Arbitrum One (vault pointed at native USDC):

```sh
export ARBITRUM_RPC_URL=https://arb1.arbitrum.io/rpc
USDC_ADDRESS=0xaf88d065e77c8cC2239327C5EDb3A432268e5831 \
OWNER=0x... \
PRIVATE_KEY=0x... forge script script/Deploy.s.sol \
  --rpc-url $ARBITRUM_RPC_URL --broadcast --verify
```

Native USDC on Arbitrum One: `0xaf88d065e77c8cC2239327C5EDb3A432268e5831`
Native USDC on Arbitrum Sepolia: `0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d`

## Roadmap

1. Savings pools (this repo) + testnet demo.
2. White-label deployments for partners.
3. Borrowing against savings.
4. Audit, guarded mainnet launch with deposit cap.
