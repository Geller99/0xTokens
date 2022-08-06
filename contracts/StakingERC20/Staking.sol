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
 * @dev Reward System will be implemented within this contract or Proxies
 */

contract Staking {
    /**
     * @dev sets up time tracking mechanisms
     * 
     * what about block staking? Stake now, stake more later ?
     */

    using Strings for uint256;
    // uint256 public contractBalance;
    uint256 private rewardsPercentage = 0.05;
    uint256 public initialTimestamp;
    uint256 public timePeriod;
    bool public timestampSet;
    address public owner;

     // ERC20 contract address
    IERC20 public erc20TokenContract;
    IERC20 public erc20RewardToken;

    // Events for staking, unstaking and claiming rewards
    event TokensStaked(address indexed from, uint256 amount);
    event TokensUnstaked(address indexed to, uint256 amount, uint256 rewardsAmount);
    event RewardClaimed(address indexed claimer, uint256 amount);

    
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

    function _getRewards (uint256 _amount) internal view return (uint256) {
        return rewardsPercentage * _amount;
    } 


    /**
     * @dev implements staking mechanism for by calling interface methods of the IERC20 standard
     * @dev will calculate rewards according to 'amount' of tokens staked
     */
    function stakeTokens(IERC20 token, uint256 amount) external public returns (bool) {
        require(amount <= IERC20(tokenContract).balanceOf(msg.sender), "You do not have enough funds to stake!");

    // if staker already exists, update stake amount, time and recalculate % rewards 
        if (staker[msg.sender].isStaked == true ) {            
            token.safeTransferFrom(msg.sender, address(this), amount);
            staker[msg.sender].amount += amount;
            staker[msg.sender].stakeTime += 6000;
            staker[msg.sender].rewards += _getRewards(staker[msg.sender].amount);
            
        } else {

        token.safeTransferFrom(msg.sender, address(this), amount);
        Staker newStaker = new Staker(amount, 6000, true, _getRewards(amount));
        stakers[msg.sender] = newStaker;
        }

        emit tokensStaked(msg.sender, amount);
    } 

    function unStakeToken(IERC20 token, uint256 amount) public returns (bool) {
        require(staker[msg.sender].isStaked == true, "You cannot unstake at this time");
        require(staker[msg.sender].amount > 0, "You do not have any tokens staked");

        /**
         * @dev autoclaims rewards if staker forgot to claim rewards before unstaking
         * @dev updates staker struct amount and rewards and changes isStaked State
         */
        if (block.timestamp >= timePeriod) {
            if (staker[msg.sender].rewards > 0) claimRewards();
            staker[msg.sender].amount -= amount;
            staker[msg.sender].amount < 1 ? staker[msg.sender].isStaked = false : staker[msg.sender].isStaked = true;
            staker[msg.sender].amount < 1 ? staker[msg.sender].rewards = 0 : staker[msg.sender].rewards = _getRewards(staker[msg.sender].amount) ;
            token.safeTransfer(msg.sender, amount);
            emit TokensUnstaked(msg.sender, amount);
        } else {
            revert("Tokens are only available after correct time period has elapsed");
        }
        return true;
    }

    /**
     * @dev calls IERC20 mint on the rewards token to the address of the claimer based on their % of rewards
     */
    function claimRewards() external public returns (bool) {
        require(staker[msg.sender].rewards > 0, "You cannot claim rewards at this time");
        require(staker[msg.sender].isStaked == true, "Cannot claim rewards, not active staker");
        IERC20(erc20RewardToken).mint(msg.sender, staker[msg.sender].rewards);
        staker[msg.sender].rewards = 0;
        return true;
    }


    function getVaulTotalBalance () external public view returns (uint256) {
      return IERC20(erc20TokenContract).balanceOf(address(this));
    } 

    function getIndividualStakerBalance () external public view returns (uint256) {
        return stakers[msg.sender].amount;
    }

}