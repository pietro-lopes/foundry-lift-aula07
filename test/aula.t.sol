// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/aula.sol";
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
        liftAmm = new LiftAMM(
            "Lift aula 7 - AMM",
            "LiftAMM",
            address(tokenA),
            address(tokenB),
            3
        );
        // Daremos o máximo possível de Ether pra essa conta
        vm.deal(owner, Test.UINT256_MAX);
    }

    // Testando endereços dos tokens do LiftAMM
    function testTokenAddresses() public {
        assertEq(liftAmm.tokenA(), address(tokenA));
        assertEq(liftAmm.tokenB(), address(tokenB));
    }

    // Testando addLiquidity
    function testAddLiquidity() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(liftAmm), amountA);
        tokenB.approve(address(liftAmm), amountB);

        liftAmm.addLiquidity(amountA, amountB);

        uint256 ammTokenABalance = tokenA.balanceOf(address(liftAmm));
        uint256 ammTokenBBalance = tokenB.balanceOf(address(liftAmm));

        uint256 liquidity = liftAmm.balanceOf(address(owner));

        assertEq(ammTokenABalance, amountA);
        assertEq(ammTokenBBalance, amountB);
        assertEq(liquidity, 3162277660168379331);
    }

    // Testando removeLiquidity
    function testRemoveLiquidity() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(liftAmm), amountA);
        tokenB.approve(address(liftAmm), amountB);
        liftAmm.addLiquidity(amountA, amountB);
        uint256 liquidity = liftAmm.balanceOf(address(owner));

        liftAmm.removeLiquidity(liquidity);

        uint256 ammTokenABalance = tokenA.balanceOf(address(liftAmm));
        uint256 ammTokenBBalance = tokenB.balanceOf(address(liftAmm));
        uint256 liquidityAfter = liftAmm.balanceOf(address(owner));

        assertEq(ammTokenABalance, 0);
        assertEq(ammTokenBBalance, 0);
        assertEq(liquidityAfter, 0);
    }

    // Testando swap B -> A
    function testSwapTokenBForTokenA() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(liftAmm), amountA);
        tokenB.approve(address(liftAmm), amountB);
        liftAmm.addLiquidity(amountA, amountB);

        uint256 amountIn = 1 ether;
        tokenB.approve(address(liftAmm), amountIn);
        uint256 time = block.timestamp + 5 minutes;
        uint256 slippage = 0;
        uint256 amountOut = liftAmm.swap(
            address(tokenB),
            amountIn,
            slippage,
            time
        );

        assertApproxEqAbs(amountOut, 90661089388014914, 1);
    }

    // Testando swap A -> B
    function testSwapTokenAForTokenB() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(liftAmm), amountA);
        tokenB.approve(address(liftAmm), amountB);
        liftAmm.addLiquidity(amountA, amountB);

        uint256 amountIn = 0.5 ether;
        tokenA.approve(address(liftAmm), amountIn);
        uint256 time = block.timestamp + 5 minutes;
        uint256 slippage = 0;
        uint256 amountOut = liftAmm.swap(
            address(tokenA),
            amountIn,
            slippage,
            time
        );

        assertApproxEqAbs(amountOut, 3326659993326659993, 1);
    }

    // Testando SwapFailSlippage
    function testSwapFailSlippage() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(liftAmm), amountA);
        tokenB.approve(address(liftAmm), amountB);
        liftAmm.addLiquidity(amountA, amountB);

        uint256 amountIn = 1 ether;
        tokenB.approve(address(liftAmm), amountIn);

        uint256 amountOutPrev = 90661089388014914;

        uint256 time = block.timestamp + 5 minutes;
        uint256 slippage = amountOutPrev + 1;
        vm.expectRevert(
            "Slippage Protection: Amount less then Minimum requested"
        );
        liftAmm.swap(address(tokenB), amountIn, slippage, time);
    }

    // Testando SwapFailSlippage
    function testSwapFailDeadLine() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(liftAmm), amountA);
        tokenB.approve(address(liftAmm), amountB);
        liftAmm.addLiquidity(amountA, amountB);

        uint256 amountIn = 1 ether;
        tokenB.approve(address(liftAmm), amountIn);
        uint256 timestamp = block.timestamp;
        uint256 delay = 5 minutes;
        vm.warp(timestamp + delay + 1);
        uint256 slippage = 0;
        vm.expectRevert(
            "Time lock protection : timestamp greater then deadline"
        );
        liftAmm.swap(address(tokenB), amountIn, slippage, timestamp);
    }
}
