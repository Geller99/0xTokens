
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin-contracts/contracts/Strings.sol";
import "@openzeppelin-contracts/Ownable.sol";



/**
 * @dev instance of TokenSwap V1 -
 * 
 * @dev user provides two tokens, tokenSwap creates a pool instance (contract)
 * 
 * @dev Pool instance is a contract that holds two tokens - users can swap one for another, or add to the liquidity pool
 * 
 * @dev Reward mechanism for LP Providers is ERC20 - 'xRED' 
 * 
 */


contract TokenSwap is Ownable {

    /**
     * @dev keeps track of LP Providers
     */
    struct LiquidityProvider {
         address tokeOne;
         address tokenTwo;
         bool isProvider;
         uint256 amountTokenOne;
         uint256 amountTokenTwo;
    }

    
    struct TokenPairs {
        address PairContract;
        IERC20 tokenOne;
        IERC20 tokenTwo;
    }

    mapping (address => LiquidityProvider) public providers;
    mapping (address => mapping (address => TokenPairs)) private pairContracts;
    

    constructor () {

    }

    // Events
    event PoolCreated (address _poolContract, address tokenOne, address tokenTwo);
    event LiquidityAdded (address _provider, uint256 amountTokenOne, uint256 amountTokenTwo);
    event LiquidityRemoved (address _provider, uint256 amountTokenOne, uint256 amountTokenTwo);
    event TokenSwapped (address _user, uint256 amountTokenOne, uint256 amountTokenTwo);
    event RewardClaimed (address _provider, uint256 amount);
    

    /**
     * @dev function creates pool with interfaces of both tokens supplied, and the amounts committed to the pool
     */
    function createPool(address tokenA, address tokenB, uint256 amountTokenA, uint256 amountTokenB) public returns (address) {
        require(amountTokenA > 0 && amountTokenB > 0, 'Invalid supply of tokens for pooling');
        (address _token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        (address amountToken0, address amountToken1) = tokenA < tokenB ? (amountTokenA, amountTokenB) : (amountTokenB, amountTokenA);
        require(pairContracts[token0][token1] == 0, 'Pool already exists for this token pair, add to existing pool');
    // create new token pair contract, store address and
        PairContract myPair = new PairContract(token0, token1);
    /**
     * @dev NEEDs to sort token addresses before assigning?
     */
        pairContracts[token0][token1] = address(myPair);
        providers[msg.sender] = LiquidityProvider(token0, token1, true, amountToken0, amountToken1);
        
        IERC20(token0).transferFrom(msg.sender, address(myPair), amountToken0);
        IERC20(token1).transferFrom(msg.sender, address(myPair), amountToken1);

        emit PoolCreated(address(myPair), token0, token1);

        return address(myPair);
    }


    /**
     * @dev function checks the list of created pairContracts/Pools for tokens that match the user's desired swapping pair
     *      performs swap using approval from TokenSwap as owner
     *      emits event confirming tokenSwap
     * 
     */

    function findPairContractAddress (IERC20 _tokenOne IERC20 _tokenTwo) internal view returns (bool, address) {
        require(address(_userToken) != address(0), "Invalid token entered");
        /**
         * @dev sorts inputed tokens to match existing key-value structure in pools
         */
        (address(_tokenOne), address (_tokenTwo)) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        TokenPairs targetPair = pairContracts[_userToken][_targetToken];
        return (true, address(targetPair));  
    }

    function swapTokensFromPool (IERC20 _userToken, IERC20 _targetToken, uint256 _amountSwappable) {
        (bool success, poolContractAddress) = findPairContractAddress(_userToken, _targetToken);
        require(success, "Zero liquidity for this token pair");
        // call tokenTransfer
    }


    /**
     * @dev checks if token pair already exists, and creates new pair contract OR increments existing pool pair
     */
    function addLiquidity () {

    }


    /**
     * @dev checks time period of liqudiity staking and removes tokens when it elapses
     */
    function removeLiquidity () {

    }

}