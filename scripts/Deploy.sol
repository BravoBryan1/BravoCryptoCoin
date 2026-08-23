// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/BravoCryptoCoin.sol";

/**
 * @title BravoCryptoCoinDeployment
 * @dev Deployment script for BravoCryptoCoin on Flare Network
 * 
 * Network: Flare (mainnet) and Songbird (testnet)
 * Token: BBCC (BravoCryptoCoin)
 * Total Supply: 77,000,000 tokens
 */

contract BravoCryptoCoinDeployment {
    
    // Network configurations
    struct NetworkConfig {
        string name;
        string rpcUrl;
        uint256 chainId;
        bool isTestnet;
    }
    
    // Deployment addresses
    struct DeploymentAddresses {
        address tokenContract;
        address songbirdDistributor;
        address flareMainnetPool;
        address delegationPool;
        address charityWallet;
        address teamWallet;
    }
    
    // Network configs
    NetworkConfig public songbirdConfig = NetworkConfig(
        "Songbird",
        "https://songbird.towolabs.com/rpc",
        16,
        true
    );
    
    NetworkConfig public flareConfig = NetworkConfig(
        "Flare",
        "https://flare.towolabs.com/rpc",
        14,
        false
    );
    
    // Deployment storage
    mapping(uint256 => DeploymentAddresses) public deployments;
    mapping(uint256 => address) public tokenContracts;
    
    // Events
    event ContractDeployed(address indexed contractAddress, uint256 chainId, string networkName);
    event Phase1Initialized(address indexed songbirdAddress, address indexed mainnetAddress, uint256 timestamp);
    event Phase2Initialized(address indexed delegationPool, address indexed charityWallet, uint256 timestamp);
    
    /**
     * @dev Deploy token contract to specified network
     */
    function deployToken() external returns (address) {
        BravoCryptoCoin token = new BravoCryptoCoin();
        emit ContractDeployed(address(token), block.chainid, getNetworkName(block.chainid));
        tokenContracts[block.chainid] = address(token);
        return address(token);
    }
    
    /**
     * @dev Initialize Phase 1 deployment
     * Releases tokens to Songbird testnet and Flare mainnet
     */
    function initializePhase1Deployment(
        address tokenAddress,
        address songbirdAddress,
        address mainnetAddress,
        address teamAddress
    ) external {
        BravoCryptoCoin token = BravoCryptoCoin(tokenAddress);
        token.releasePhase1(songbirdAddress, mainnetAddress, teamAddress);
        
        emit Phase1Initialized(songbirdAddress, mainnetAddress, block.timestamp);
    }
    
    /**
     * @dev Initialize Phase 2 deployment
     * Releases tokens for delegation, liquidity, farming, and staking
     */
    function initializePhase2Deployment(
        address tokenAddress,
        address delegationPool,
        address charityWallet
    ) external {
        BravoCryptoCoin token = BravoCryptoCoin(tokenAddress);
        token.releasePhase2(delegationPool, charityWallet);
        
        emit Phase2Initialized(delegationPool, charityWallet, block.timestamp);
    }
    
    /**
     * @dev Get network name by chain ID
     */
    function getNetworkName(uint256 chainId) internal pure returns (string memory) {
        if (chainId == 16) return "Songbird";
        if (chainId == 14) return "Flare";
        return "Unknown";
    }
    
    /**
     * @dev Get deployment status
     */
    function getDeploymentStatus(address tokenAddress) external view returns (
        bool phase1Initialized,
        bool phase2Started,
        bool phase3Unlocked,
        uint256 vaultBalance,
        uint256 contractBalance
    ) {
        BravoCryptoCoin token = BravoCryptoCoin(tokenAddress);
        return (
            token.phase1Initialized(),
            token.phase2Started(),
            token.phase3Unlocked(),
            token.getVaultBalance(),
            token.getContractBalance()
        );
    }
}
