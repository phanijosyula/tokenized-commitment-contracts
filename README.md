# Tokenized Commitment Contracts

A smart contract system to enforce user accountability through on-chain, time-bound token pledges. Users stake tokens against a task or promise and must submit proof to reclaim their funds.

## Features

- ERC-20 compatible
- Commitment creation with token lock and validator assignment
- Proof submission and validator-based approval
- Refund or slashing based on success/failure
- Optional NFT minting hook (future extension)

## Smart Contract

Deployed contract: `CommitmentContract.sol`

## Functions

- `createCommitment(...)`: Create a new time-bound task with locked tokens.
- `submitProof(...)`: Submit proof of task completion.
- `validateCommitment(...)`: Validator approves or rejects proof.
- `claim(...)`: Committer reclaims tokens if successful.
- `slashExpired(...)`: Slash tokens if deadline missed without proof.

## Getting Started

1. Install Hardhat and dependencies:
```bash
npm install --save-dev hardhat
```

2. Compile contract:
```bash
npx hardhat compile
```

3. Test and deploy (scripts coming soon).

## License

MIT
