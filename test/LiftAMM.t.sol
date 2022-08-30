// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/LiftAMM.sol";
import "../src/Token.sol";

contract LiftAMMTest is Test {
    Token public tokenA;
    Token public tokenB;
    LiftAMM public liftAmm;
    address public owner = vm.addr(1);

    // Criando contrato
    function setUp() public {
        // Criando label pra facilitar debug caso necessário
        vm.label(owner, "Owner");
        // Ativando a conta owner pra dar deploy nos contratos
        vm.startPrank(owner);
        tokenA = new Token("TokenA", "TKA");
        tokenB = new Token("TokenB", "TKB");
        liftAmm = new LiftAMM(address(tokenA), address(tokenB));
        // Daremos o máximo possível de Ether pra essa conta
        vm.deal(owner, Test.UINT256_MAX);
    }

    // Testando endereços dos tokens do LiftAMM
    function testLiftAMMTokenAddresses() public {
        assertTrue(liftAmm.tokenA() == address(tokenA));
        assertTrue(liftAmm.tokenB() == address(tokenB));
    }

    // Testando addLiquidity LiftAMM
    function testLiftAMMAddLiquidity() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(liftAmm), amountA);
        tokenB.approve(address(liftAmm), amountB);

        liftAmm.addLiquidity(amountA, amountB);

        uint256 ammTokenABalance = tokenA.balanceOf(address(liftAmm));
        uint256 ammTokenBBalance = tokenB.balanceOf(address(liftAmm));

        uint256 liquidity = liftAmm.balance(address(owner));

        assertTrue(ammTokenABalance == amountA);
        assertTrue(ammTokenBBalance == amountB);
        assertTrue(liquidity == 3162277660168379331);
    }

    // Testando removeLiquidity LiftAMM
    function testLiftAMMRemoveLiquidity() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(liftAmm), amountA);
        tokenB.approve(address(liftAmm), amountB);
        liftAmm.addLiquidity(amountA, amountB);
        uint256 liquidity = liftAmm.balance(address(owner));

        liftAmm.removeLiquidity(liquidity);

        uint256 ammTokenABalance = tokenA.balanceOf(address(liftAmm));
        uint256 ammTokenBBalance = tokenB.balanceOf(address(liftAmm));
        uint256 liquidityAfter = liftAmm.balance(address(owner));

        assertTrue(ammTokenABalance == 0);
        assertTrue(ammTokenBBalance == 0);
        assertTrue(liquidityAfter == 0);
    }

    // Testando addLiquidity LiftAMM
    function testLiftAMMSwap() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(liftAmm), amountA);
        tokenB.approve(address(liftAmm), amountB);
        liftAmm.addLiquidity(amountA, amountB);

        uint256 amountIn = 1 ether;
        tokenB.approve(address(liftAmm), amountIn);
        liftAmm.swap(address(tokenB), amountIn);

        uint256 ammTokenABalance = tokenA.balanceOf(address(liftAmm));
        uint256 amountOut = amountA - ammTokenABalance;

        assertTrue(amountOut == 90909090909090910);
    }

    receive() external payable {}
}
