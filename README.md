# LilPOL: A Simplified Proof of Liquidity Implementation
![Alt text](../img/lilpol.png)
## Overview

LilPOL is a minimalist implementation of the Proof of Liquidity (POL) consensus mechanism, designed to demonstrate the core principles of POL in a simplified, educational format. This project consists of two main contracts: LilPOL and LilBGT, which together simulate the essential functions of a POL system.

## What is Proof of Liquidity (POL)?

Proof of Liquidity is a novel consensus mechanism that aims to align network incentives, creating strong synergy between validators and the ecosystem of projects. In POL:

1. Validators provide liquidity to the network instead of just staking tokens.
2. Block rewards are distributed based on the amount of liquidity provided.
3. Projects can incentivize liquidity provision to their protocols, influencing validator behavior.

## Core Components

### LilPOL Contract

The LilPOL contract serves as the central hub for managing validators, distributing rewards, and handling the core POL mechanics. It includes:

- Validator management
- Cutting board functionality (reward distribution preferences)
- Block reward processing and distribution
- Basic staking mechanics

### LilBGT Contract

The LilBGT contract represents a simplified version of the Bera Governance Token, which is central to the POL ecosystem. It handles:

- Token minting and transfers
- Boost queuing and management
- Commission rate setting for validators
- Reward rate calculations

## Core Principles and Functionality

1. Validator Management:
    - Validators are registered and tracked in the system.
    - Each validator has an associated operator address.

2. Cutting Boards:
    - Validators can set preferences for how their rewards are distributed.
    - Cutting boards can be queued and activated after a delay.

3. Reward Distribution:
    - Block rewards are calculated based on base rates and validator-specific boosts.
    - Rewards are distributed according to active cutting boards.

4. Boosting Mechanism:
    - Token holders can queue boosts for validators.
    - Boosts increase a validator's share of rewards.

5. Commission Rates:
    - Validators can set commission rates to earn a portion of rewards.

6. Block Timing:
    - Certain actions (like activating cutting boards or changing commission rates) are subject to block number-based delays.

7. Liquidity Provision:
    - While simplified in this implementation, the core idea is that validators provide liquidity to earn rewards.

## How It Works Together

1. Validators register in the LilPOL contract.
2. Token holders acquire LilBGT tokens.
3. Token holders can boost validators using their LilBGT.
4. Validators set up cutting boards to direct their rewards.
5. As blocks are produced, the LilPOL contract calculates and distributes rewards.
6. The LilBGT contract handles token minting, transfers, and boost management.

## Key Differences from Full POL Implementation

- Simplified mechanics and fewer safety checks.
- Limited governance features.
- Reduced complexity in liquidity tracking and management.
- Minimal implementation of advanced features like delegation or complex reward strategies.

## Usage

This project is intended for educational purposes and as a starting point for understanding POL mechanics. It is not suitable for production use without significant enhancements and security audits.

To interact with the contracts:
1. Deploy LilBGT and LilPOL contracts.
2. Set up validators and initial token distribution.
3. Experiment with boosting, cutting board management, and reward distribution.

## Future Enhancements

To move towards a more complete POL system, consider adding:
- More sophisticated liquidity tracking and management.
- Enhanced governance features.
- Improved security measures and invariant checks.
- Integration with DeFi protocols for real liquidity provision.