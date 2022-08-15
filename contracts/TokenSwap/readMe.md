
## TokenSwap ERC20 ##


**this** Smart Contract is a simple implementation of a DeFi tokenswap mechanism

The general mechanism involves

- A TokenSwap Contract that acts as a factory to create contracts with token pairs
- Token pairs act as liquidity pools 
- Swaps happen when one token is requested from the pool in exchange for another
- Pools are created when Liquidity provider adds tokens that did not previously exist



## Design, Implementation, Architecture ##

The most intuitive approach to creating ``pools`` is the standard factory mechanism which securely implements a trustless system with all transactions dependent on how many tokens exist in the pool, the x*y bond curve and the parent contract existing a layer above pool instances.

Diving deeper into the model, our approach to solving this problem involves representing every LiquidityProvider with a struct - and recording every transaction they execute in order to track the amounts of each token deposited into pools.

The next step involves solving the problem of FINDING the right pools when users are looking to perform a swap.


 **situation**
 
- Factory contract creates multiple ``pairContract`` that each accept two tokens in a ratio
- User comes to Factory and wants to swap token
- Factory needs to search through its 'list' of ``pairContracts`` and see which one matches the swap the user is looking to perform
- How would you store these contract addresses so you can search em out in O(n) time

```
Thinking....

struct TokenPair {
   IERC20 tokenOne;
   IERC20 tokenTwo;
}
then 

(address => TokenPair) 

And store them in mapping ?? 

```
But then the contract doesn't really have a way of CHECKING which one of the pairContract contains two tokens that match what the user is swapping with and what they're swapping for...

Interestingly, python lets you store tupes as KEYS...in key/value stores....Solidity does not support this functionality just yet.

Another noob approach I cameup with was storing the data pairs in a dynamic array but is WAY too expensive in Solidity - O(n) time gets more and more expensive as more pools are created.



## Potential Solutions - (suggested by Squeebo_nft) ##

1) We could set up a string key which is the concatenation of both addresses.  This mapping would point to a specific pair ID
2a) We can also set up a mapping to a mapping, but then we’d incure double storage.
2b) We can perform the lookup on the browser, then feed in the pair ID - this is the cheapest for gas and let’s you save storage



## Key Takeaways ##

Each of these solution variants will be implemented as V1-V2-V3 branches

For the sake of rapid implementation, we'll be moving forward with the first option to get the contract compiling and testing the mechanism

