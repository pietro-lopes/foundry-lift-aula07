// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Import this file to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LiftAMM is ERC20 {
    // mapping(address => uint256) public balance;

    address public immutable tokenA;
    address public immutable tokenB;

    constructor(address _tokenA, address _tokenB)
        ERC20("Lift LP Token", "LPToken")
    {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    // Raiz quadrada: https://github.com/Uniswap/v2-core/blob/master/contracts/libraries/Math.sol
    function _squareRoot(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function addLiquidity(uint256 amountA, uint256 amountB)
        external
        returns (uint256 liquidity)
    {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        uint256 balanceA = IERC20(tokenA).balanceOf(address(this));
        uint256 balanceB = IERC20(tokenB).balanceOf(address(this));

        uint256 _totalSupply = this.totalSupply();
        require(
            (_totalSupply * amountA) / balanceA ==
                (_totalSupply * amountB) / balanceB,
            "Wrong proportion between asset A and B"
        );

        liquidity = _squareRoot(amountA * amountB);
        // totalSupply += liquidity;
        // balance[msg.sender] += liquidity;
        _mint(msg.sender, liquidity);
    }

    function removeLiquidity(uint256 liquidity)
        external
        returns (uint256 amountA, uint256 amountB)
    {
        require(
            this.balanceOf(msg.sender) >= liquidity,
            "Not enough liquidity for this, amount too big"
        );
        uint256 balanceA = IERC20(tokenA).balanceOf(address(this));
        uint256 balanceB = IERC20(tokenB).balanceOf(address(this));

        uint256 _totalSupply = this.totalSupply();
        uint256 divisor = _totalSupply / liquidity;
        amountA = balanceA / divisor;
        amountB = balanceB / divisor;

        // totalSupply -= liquidity;
        // balance[msg.sender] -= liquidity;
        _burn(msg.sender, liquidity);
        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);
    }

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "EXPIRADO");
        _;
    }

    // modificado external pra public pra ser possível chamar internamente também
    function swap(
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 deadline
    ) external ensure(deadline) returns (uint256 amountOut) {
        uint256 newBalance;
        require(tokenIn == tokenA || tokenIn == tokenB, "TokenIn not in pool");

        uint256 balanceA = IERC20(tokenA).balanceOf(address(this)); // X
        uint256 balanceB = IERC20(tokenB).balanceOf(address(this)); // Y

        uint256 k = balanceA * balanceB; // K = X * Y

        if (tokenIn == tokenA) {
            IERC20(tokenA).transferFrom(msg.sender, address(this), amountIn);
            uint256 amountInWithFee = (amountIn * 997) / 1000;
            newBalance = k / (balanceA + amountInWithFee);
            amountOut = balanceB - newBalance;
            require(amountOut >= amountOutMin, "Slippage Insuficiente");
            IERC20(tokenB).transfer(msg.sender, amountOut);
        } else {
            IERC20(tokenB).transferFrom(msg.sender, address(this), amountIn);
            uint256 amountInWithFee = (amountIn * 997) / 1000;
            newBalance = k / (balanceB + amountInWithFee);
            amountOut = balanceA - newBalance;
            require(amountOut >= amountOutMin, "Slippage Insuficiente");
            IERC20(tokenA).transfer(msg.sender, amountOut);
        }
    }
}
