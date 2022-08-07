// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin-contracts/contracts/Strings.sol";
import "@openzeppelin-contracts/Ownable.sol";

/**
 * @dev is a contract for staking ERC20 tokens for a specific amount of time for rewards
 * 
 * @dev Stakers can redeem reward tokens, restake rewards for extra rewards  OR claim rewards and unstake after a certain amount of days
 * 
 * @dev Reward System will be implemented within this contract 
 * 
 * @dev V2 Reward system will implement factory pattern
 */

contract Staking {
    /**
     * @dev sets up time tracking mechanisms
     * 
     * what about block staking? Stake now, stake more later ?
     */

    using Strings for uint256;
    bool public timestampSet;
    address public owner;
    uint256 private rewardsPercentage = 5;
    uint256 public initialTimestamp;
    uint256 public timePeriod;
    
 
     // ERC20 contract address
    IERC20 public erc20TokenContract;
    IERC20 public erc20RewardToken;

    // Events for staking, unstaking and claiming rewards
    event TokensStaked(address indexed from, uint256 amount);
    event TokensUnstaked(address indexed to, uint256 amount);
    event RewardClaimed(address indexed claimer, uint256 amount);

    error StakingFailed();
    
    constructor(IERC20 erc20TokenAddress, IERC20 rewardTokenAddress) {
        owner = msg.sender;
        // Timestamp values not set yet
        timestampSet = false;
        // Set the erc20 contract address 
        require(address(erc20TokenAddress) != address(0), "Please enter a valid token address");
        require(address(rewardTokenAddress) != address(0), "Please enter a valid token address");
        erc20TokenContract = erc20TokenAddress;
        erc20RewardToken = rewardTokenAddress;

    }
    // Staker Data
    struct Staker {
        uint256 amount;
        uint256 stakeTime;
        uint256 rewards;
        bool isStaked;
    }

    mapping (address => Staker) public stakers;

    function setTimestamp(uint256 _timePeriodInSeconds) public onlyOwner {
        require(timestampSet == false, "The time stamp has already been set.");
        timestampSet = true;
        initialTimestamp = block.timestamp;
        timePeriod = initialTimestamp + _timePeriodInSeconds;
    }

    function _getRewards (uint256 _amount) internal view returns (uint256) {
        return rewardsPercentage * _amount;
    } 


    /**
     * @dev implements staking mechanism for by calling interface methods of the IERC20 standard
     * @dev will calculate rewards according to 'amount' of tokens staked
     */
    function stakeTokens(IERC20 token, uint256 amount)  public returns (bool) {
        require(timestampSet == true, "Cannot stake, staking period not yet specified");
        require(amount <= IERC20(erc20TokenContract).balanceOf(msg.sender), "You do not have enough funds to stake!");

    // if staker already exists, update stake amount, time and recalculate % rewards 
        if (stakers[msg.sender].isStaked == true ) {            
            token.transferFrom(msg.sender, address(this), amount);
            stakers[msg.sender].amount += amount;
            stakers[msg.sender].stakeTime += 6000;
            stakers[msg.sender].rewards += _getRewards(stakers[msg.sender].amount);
            
        } else {
        bool success = token.transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert StakingFailed();
        }
        Staker memory newStaker = Staker(amount, 6000, _getRewards(amount), true);
        stakers[msg.sender] = newStaker;
        }

        emit TokensStaked(msg.sender, amount);
        return true;
    } 

    function unStakeToken(IERC20 token, uint256 amount) public returns (bool) {
        require(stakers[msg.sender].isStaked == true, "You cannot unstake at this time");
        require(stakers[msg.sender].amount > 0, "You do not have any tokens staked");

        /**
         * @dev autoclaims rewards if staker forgot to claim rewards before unstaking
         * @dev updates staker struct amount and rewards and changes isStaked State
         */
        if (block.timestamp >= timePeriod) {
            if (stakers[msg.sender].rewards > 0) claimRewards();
            stakers[msg.sender].amount -= amount;
            stakers[msg.sender].amount < 1 ? stakers[msg.sender].isStaked = false : stakers[msg.sender].isStaked = true;
            stakers[msg.sender].amount < 1 ? stakers[msg.sender].rewards = 0 : stakers[msg.sender].rewards = _getRewards(stakers[msg.sender].amount) ;
            token.transfer(msg.sender, amount);
            emit TokensUnstaked(msg.sender, amount);
        } else {
            revert("Tokens are only available after correct time period has elapsed");
        }
        return true;
    }

    /**
     * @dev calls IERC20 mint on the rewards token to the address of the claimer based on their % of rewards
     * @dev Rewards can only be claimed halfway through the staking period
     */
    function claimRewards() public returns (bool) {
        require(block.timestamp >= timePeriod/2, "Staking period not yet over, try again later");
        require(stakers[msg.sender].rewards > 0, "You cannot claim rewards at this time");
        require(stakers[msg.sender].isStaked == true, "Cannot claim rewards, not active staker");

        // IERC20(erc20RewardToken).mint(msg.sender, stakers[msg.sender].rewards);
        stakers[msg.sender].rewards = 0;
        return true;
    }


    function getVaulTotalBalance () external view returns (uint256) {
      return IERC20(erc20TokenContract).balanceOf(address(this));
    } 

    function getIndividualStakerBalance () public view returns (uint256) {
        return stakers[msg.sender].amount;
    }

    function setRewardsPercentage (uint8 _percentage) public onlyOwner {
        rewardsPercentage = _percentage;
    }

}