# GitBeacon

A simplified version control system in the solidity language using the beacon pattern

# Deployment Instructions for GitBeacon

This guide provides step-by-step instructions for deploying and interacting with the GitBeacon system on any EVM-compatible blockchain.

## Prerequisites

- [Foundry](https://getfoundry.sh/) installed
- An Ethereum wallet with funds for gas
- Access to an RPC endpoint for your target network

## Environment Setup

Create a `.env` file in your project root with the following variables:

```bash
PRIVATE_KEY=your_private_key_here
SEPOLIA_RPC_URL=your_rpc_url_here
ETHERSCAN_API_KEY=your_etherscan_api_key
```

Then load these environment variables:

```bash
source .env
```

## Deployment Steps

### 1. Initial Deployment

This step deploys the initial implementation (CounterV1), the GitBeacon contract, and a proxy.

```bash
forge script script/Deploy.s.sol:DeployGitBeacon --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

The script will output the addresses of all deployed contracts. Save these addresses for future reference:

```
CounterV1 implementation deployed at: 0x...
GitBeacon deployed at: 0x...
Proxy deployed at: 0x...
```

### 2. Interacting with the Proxy

Example using cast (Foundry's CLI tool):

```bash
# Call the get() function on the proxy (which delegates to CounterV1)
cast call <PROXY_ADDRESS> "get()" --rpc-url $SEPOLIA_RPC_URL
```

### 3. Deploying a New Implementation

When you want to upgrade your contract:

```bash
# Set the GitBeacon address from step 1
export GIT_BEACON_ADDRESS=<GIT_BEACON_ADDRESS>

# Deploy a new implementation and upgrade
forge script script/Deploy.s.sol:DeployNewImplementation --rpc-url $SEPOLIA_RPC_URL --broadcast
```

After this step, the proxy will automatically point to the new implementation.

### 4. Rolling Back to a Previous Version

If you need to revert to a previous implementation:

```bash
forge script script/Deploy.s.sol:RollbackImplementation --rpc-url $SEPOLIA_RPC_URL --broadcast
```

### 5. Checking the Current Implementation

To verify which implementation the system is currently using:

```bash
# Get the current implementation address
cast call <GIT_BEACON_ADDRESS> "getCurrentVersion()" --rpc-url $SEPOLIA_RPC_URL

# Get the total number of versions in history
cast call <GIT_BEACON_ADDRESS> "getVersionHistoryCount()" --rpc-url $SEPOLIA_RPC_URL
```

## Advanced Usage

### Skipping Multiple Versions

To move forward multiple versions at once, call `updateInc()` multiple times:

```bash
# Move forward 2 versions
cast send <GIT_BEACON_ADDRESS> "updateInc()" --private-key $PRIVATE_KEY --rpc-url $SEPOLIA_RPC_URL
cast send <GIT_BEACON_ADDRESS> "updateInc()" --private-key $PRIVATE_KEY --rpc-url $SEPOLIA_RPC_URL
```
