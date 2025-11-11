# AuraSoulsV1 Fuzz Test Suite

Production-grade Echidna/Foundry fuzz test suite using the UniversalFuzzing framework.

## Overview

This repository contains a comprehensive fuzz test suite for the AuraSoulsV1 bonding curve protocol. The suite implements 12 meaningful invariants and uses handler-based fuzzing with proper precondition/postcondition separation.

## Quick Start

### Prerequisites
```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install Echidna
curl -fsSL https://guardianexec-echidna.nyc3.digitaloceanspaces.com/echidna -o /usr/local/bin/echidna
chmod +x /usr/local/bin/echidna
```

### Installation
```bash
# Install dependencies
forge install

# Build
forge build
```

### Running Fuzz Tests

```bash
# Quick test (100 runs)
echidna test/fuzzing/Fuzz.sol --contract Fuzz --config echidna.yaml --test-limit 100

# Full campaign
echidna test/fuzzing/Fuzz.sol --contract Fuzz --config echidna.yaml

# Foundry tests
forge test --mp test/foundry/FoundryPlayground.sol -vvvv
```

## Protocol

**AuraSoulsV1** - A friend.tech-style bonding curve protocol where:
- Users buy/sell "souls" of subjects
- Price increases quadratically with supply
- First soul must be bought by the subject
- Cannot sell the last soul
- Fees distributed to protocol, subject, and LP bucket

## Invariants

The suite tests 12 critical invariants:

**Global (GLOB)**:
1. Conservation of souls (sum of balances = supply)
2. Supply never negative  
3. Fee percentages <= 100%
4. Creator earnings never decrease
5. Fee destinations never decrease

**Buy-Specific (BUY)**:
6. Supply increases by buy amount
7. Balance increases by buy amount
8. First soul rule (only subject can buy first)

**Sell-Specific (SELL)**:
9. Supply decreases by sell amount
10. Balance decreases by sell amount
11. Cannot sell last soul
12. Sufficient balance to sell

See [FUZZ_SUITE_SUMMARY.md](./FUZZ_SUITE_SUMMARY.md) for detailed documentation.

## Structure

```
test/fuzzing/
├── Fuzz.sol                    # Entry point
├── FuzzGuided.sol              # Complex scenarios
├── FuzzSetup.sol               # Deployment
├── FuzzAuraSoulsV1.sol         # Handler functions
├── helpers/
│   ├── FuzzStorageVariables.sol
│   ├── BeforeAfter.sol         # Ghost variables
│   ├── Preconditions/
│   └── Postconditions/
├── properties/
│   ├── Properties.sol          # Invariants
│   ├── Properties_ERR.sol
│   └── RevertHandler.sol
└── utils/
    └── FuzzActors.sol
```

## Status

✅ Complete fuzz suite implementation  
✅ 12 meaningful invariants  
✅ Handler-based fuzzing  
✅ Guided scenarios  
✅ FoundryPlayground reproduction tests  
⚠️ Minor compilation issues in progress (FuzzLib/forge-std event conflicts)

## License

MIT
