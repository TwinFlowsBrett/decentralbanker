# DecentralBanker — Product Overview

## What it is

DecentralBanker is a savings account that lives on the internet instead of
inside a bank. You put in digital dollars, you earn interest, and you can
take your money out at any time. There is no bank branch, no banker, and no
one who can freeze your account — the rules are enforced by software that
anyone can inspect.

## How it works (the 30-second version)

1. **Deposit.** You send digital dollars (USDC) into a DecentralBanker
   savings pool.
2. **Receipt.** You instantly get receipt tokens (dUSD) proving your share
   of the pool.
3. **Interest.** As the pool earns, every receipt token becomes worth a
   little more. Your balance grows without you doing anything.
4. **Withdraw.** Trade your receipt tokens back for digital dollars whenever
   you want.

1 receipt token starts at exactly $1.00 and only goes up as interest flows in.

## Why it is white-label

DecentralBanker is built to be rebranded. Any fintech, creator, community,
or company can launch their own savings product on these rails — their name,
their app, their customers — while the DecentralBanker engine handles
deposits, interest, and withdrawals underneath.

One engine, many storefronts:

- A freelancer app offers "Freelancer Savings" to its users.
- A gaming community offers "Guild Vault" to its players.
- A neobank offers high-yield savings without building blockchain
  infrastructure.

Each storefront is its own pool with its own cap and settings. The engine
stays the same, audited once, reused everywhere.

## Safety by design

- **Launch limits.** New pools start with a cap on total deposits until they
  prove themselves.
- **Safety switch.** Deposits and withdrawals can be paused in an emergency.
- **Open books.** Every dollar in and out is visible on a public ledger.
- **Audited parts.** Built on battle-tested open-source components, with
  professional audits before real money goes live.

## The roadmap

1. Savings pools (live in this repo).
2. White-label deployments — partners launch branded pools in days.
3. Borrowing against savings.
4. More currencies and dollar-backed options.

## For builders

Technical guide: [CONTRACTS.md](CONTRACTS.md).
Run it locally: see the project [README](../README.md).
