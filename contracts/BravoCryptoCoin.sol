// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title BravoCryptoCoin (BBCC)
 * @dev A gold-backed ERC-20 token on Flare Network with phased distribution
 * Total Supply: 77,000,000 BBCC
 * Starting Price: €5 per token
 * 
 * Distribution:
 * - Phase 1 (2026-2027): 25,666,666 tokens (immediate release + team allocation)
 * - Phase 2 (2027-2032): 25,666,666 tokens (staking, farming, delegation)
 * - Phase 3 (2045): 25,000,000 tokens (strategic vault, unlocks 29/06/2045)
 */

contract BravoCryptoCoin is ERC20, Ownable, Pausable {
    
    // ============== Constants ==============
    uint256 public constant TOTAL_SUPPLY = 77_000_000 * 10**18;
    uint256 public constant PHASE_1_AMOUNT = 25_666_666 * 10**18;
    uint256 public constant PHASE_2_AMOUNT = 25_666_666 * 10**18;
    uint256 public constant PHASE_3_AMOUNT = 25_000_000 * 10**18;
    
    // Phase 1 breakdown
    uint256 public constant SONGBIRD_TEST_AMOUNT = 666_000 * 10**18;
    uint256 public constant TEAM_ALLOCATION = 666 * 10**18;
    uint256 public constant FLARE_MAINNET_AMOUNT = 25_000_000 * 10**18;
    
    // Phase 2 breakdown
    uint256 public constant PHASE_2_DELEGATION_FARMING = 25_666_666 * 10**18;
    uint256 public constant CHARITY_ALLOCATION = 666_666 * 10**18;
    
    // Phase 3 unlock date: 29/06/2045 (Unix timestamp)
    uint256 public constant PHASE_3_UNLOCK_DATE = 2_378_188_800;
    
    uint256 public constant STARTING_PRICE_EUR = 5 * 10**18; // €5 in wei representation
    
    // ============== State Variables ==============
    
    // Phase tracking
    bool public phase1Initialized;
    bool public phase2Started;
    bool public phase3Unlocked;
    
    // Timestamps for phase releases
    uint256 public songbirdTestDate = 1_726_272_000; // 14/09/2026
    uint256 public flareMainnetDate = 1_742_169_600; // 14/03/2027
    uint256 public phase2ReleaseDate = 1_743_379_200; // 02/04/2027
    
    // Vault storage
    uint256 public phase3VaultBalance;
    
    // Token holder tracking
    mapping(address => bool) public authorizedDistributors;
    mapping(address => uint256) public stakedBalance;
    
    // Events
    event Phase1Released(uint256 songbirdAmount, uint256 mainnetAmount, uint256 timestamp);
    event Phase2Released(uint256 delegationAmount, uint256 charityAmount, uint256 timestamp);
    event Phase3UnlockedVault(uint256 amount, uint256 timestamp);
    event TokensStaked(address indexed staker, uint256 amount);
    event TokensUnstaked(address indexed staker, uint256 amount);
    event AuthorizedDistributorAdded(address indexed distributor);
    
    // ============== Constructor ==============
    
    constructor() ERC20("BravoCryptoCoin", "BBCC") {
        // Mint total supply to contract
        _mint(address(this), TOTAL_SUPPLY);
        
        // Lock Phase 3 tokens in vault
        phase3VaultBalance = PHASE_3_AMOUNT;
        
        // Authorize owner as initial distributor
        authorizedDistributors[msg.sender] = true;
    }
    
    // ============== Phase 1 Functions ==============
    
    /**
     * @dev Release Phase 1 tokens to Songbird testnet and Flare mainnet
     * - 666,000 tokens to Songbird (14/09/2026)
     * - 25,000,000 tokens to Flare mainnet (14/03/2027)
     * - 666 tokens allocated to team
     */
    function releasePhase1(address songbirdAddress, address mainnetAddress, address teamAddress) 
        external 
        onlyOwner 
        whenNotPaused 
    {
        require(!phase1Initialized, "Phase 1 already released");
        require(songbirdAddress != address(0) && mainnetAddress != address(0) && teamAddress != address(0), "Invalid addresses");
        require(block.timestamp >= songbirdTestDate, "Songbird release date not reached");
        
        // Release to Songbird testnet
        _transfer(address(this), songbirdAddress, SONGBIRD_TEST_AMOUNT);
        
        // Release to Flare mainnet
        _transfer(address(this), mainnetAddress, FLARE_MAINNET_AMOUNT);
        
        // Allocate to team
        _transfer(address(this), teamAddress, TEAM_ALLOCATION);
        
        phase1Initialized = true;
        emit Phase1Released(SONGBIRD_TEST_AMOUNT, FLARE_MAINNET_AMOUNT, block.timestamp);
    }
    
    // ============== Phase 2 Functions ==============
    
    /**
     * @dev Release Phase 2 tokens for delegation, liquidity, farming, and staking
     * - 25,666,666 tokens for the next 5 years (delegation, liquidity, farming, staking)
     * - 666,666 tokens for charity and development (02/04/2027)
     */
    function releasePhase2(address delegationPool, address charityWallet) 
        external 
        onlyOwner 
        whenNotPaused 
    {
        require(phase1Initialized, "Phase 1 must be released first");
        require(!phase2Started, "Phase 2 already started");
        require(delegationPool != address(0) && charityWallet != address(0), "Invalid addresses");
        require(block.timestamp >= phase2ReleaseDate, "Phase 2 release date not reached");
        
        // Release to delegation and farming pool
        _transfer(address(this), delegationPool, PHASE_2_DELEGATION_FARMING);
        
        // Release to charity wallet
        _transfer(address(this), charityWallet, CHARITY_ALLOCATION);
        
        phase2Started = true;
        emit Phase2Released(PHASE_2_DELEGATION_FARMING, CHARITY_ALLOCATION, block.timestamp);
    }
    
    // ============== Phase 3 Functions ==============
    
    /**
     * @dev Unlock Phase 3 vault (29/06/2045)
     * Transfers locked tokens from vault to designated recipient
     */
    function unlockPhase3Vault(address vaultRecipient) 
        external 
        onlyOwner 
    {
        require(!phase3Unlocked, "Phase 3 vault already unlocked");
        require(vaultRecipient != address(0), "Invalid recipient address");
        require(block.timestamp >= PHASE_3_UNLOCK_DATE, "Phase 3 unlock date not reached (29/06/2045)");
        
        uint256 vaultAmount = phase3VaultBalance;
        phase3VaultBalance = 0;
        phase3Unlocked = true;
        
        _transfer(address(this), vaultRecipient, vaultAmount);
        emit Phase3UnlockedVault(vaultAmount, block.timestamp);
    }
    
    // ============== Staking Functions ==============
    
    /**
     * @dev Stake tokens in the contract for farming/delegation rewards
     */
    function stake(uint256 amount) external whenNotPaused {
        require(amount > 0, "Stake amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        _transfer(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        
        emit TokensStaked(msg.sender, amount);
    }
    
    /**
     * @dev Unstake tokens from the contract
     */
    function unstake(uint256 amount) external whenNotPaused {
        require(amount > 0, "Unstake amount must be greater than 0");
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked balance");
        
        stakedBalance[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);
        
        emit TokensUnstaked(msg.sender, amount);
    }
    
    /**
     * @dev Get staked balance for an address
     */
    function getStakedBalance(address account) external view returns (uint256) {
        return stakedBalance[account];
    }
    
    // ============== Distributor Management ==============
    
    /**
     * @dev Add authorized distributor
     */
    function addAuthorizedDistributor(address distributor) external onlyOwner {
        require(distributor != address(0), "Invalid address");
        authorizedDistributors[distributor] = true;
        emit AuthorizedDistributorAdded(distributor);
    }
    
    /**
     * @dev Remove authorized distributor
     */
    function removeAuthorizedDistributor(address distributor) external onlyOwner {
        authorizedDistributors[distributor] = false;
    }
    
    /**
     * @dev Distribute tokens (only authorized distributors)
     */
    function distributeTokens(address[] calldata recipients, uint256[] calldata amounts) 
        external 
        onlyOwner 
        whenNotPaused 
    {
        require(authorizedDistributors[msg.sender] || msg.sender == owner(), "Not authorized to distribute");
        require(recipients.length == amounts.length, "Recipients and amounts length mismatch");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient");
            _transfer(address(this), recipients[i], amounts[i]);
        }
    }
    
    // ============== Utility Functions ==============
    
    /**
     * @dev Pause token transfers
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause token transfers
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Get vault balance
     */
    function getVaultBalance() external view returns (uint256) {
        return phase3VaultBalance;
    }
    
    /**
     * @dev Get contract token balance
     */
    function getContractBalance() external view returns (uint256) {
        return balanceOf(address(this));
    }
    
    /**
     * @dev Get time until Phase 3 unlock
     */
    function getTimeUntilPhase3() external view returns (uint256) {
        if (block.timestamp >= PHASE_3_UNLOCK_DATE) return 0;
        return PHASE_3_UNLOCK_DATE - block.timestamp;
    }
    
    /**
     * @dev Override _beforeTokenTransfer to enforce pause
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
    
    /**
     * @dev Receive function to accept native currency
     */
    receive() external payable {}
}
