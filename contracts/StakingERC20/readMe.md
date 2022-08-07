

## Smart Contract Coverage ##

Author - 0xDebugger 

Audited - No

Version - Development 0.01


## Technologies ##

```
- Hardhat Dev Environment
- Solidity 0.8.9
- Chai x Mocha x Waffle for Testing

```

## Structure ##

This smart contract is built for an ERC20 Staking - Reward system. The current development version features a base implementation of ``stake``, ``unstake`` and ``claimRewards``.

- Staking Mechanism
- Unstaking Mechanism
- Rewards Mechanism based on time * percentage
- Updated Staking Mechanism
- In Built Minting for RewardsToken




## Design Choices

I opted for Structs to handle staker info, making it easier to track staking status, address of staker and rewards.

In V2 we will explore using an ERC721 model which will be minted the moment a stake is completed and burned when unstaking happens.

The general approach to supplying rewards is calling the mint function on an extended ERC20 class for the reward token - in future versions we could opt for a fixed supply of reward tokens sent to the contract OR minting the reward token from the constructor the moment the contract is deployed.




## Deployment V1 ##

To deploy these contracts and engage the in-built staking-rewards mechanism, follow these steps:

- Deploy Staking.sol contract to your Network of Choice
- Open RewardToken of choice with the access control 
- Pass in address of Staking.sol as a "minter" role in the Reward Token's Constructor
- Deploy RewardToken
- Setup Proper custom timers, and reward percentage **feel free to modify contract in that regard**
- Start Staking!
- Enjoy!


## Contributors

Geller Micael

Feel free to raise issues or fork this repo and add any contributions you see fit in a separate branch

Cheers!