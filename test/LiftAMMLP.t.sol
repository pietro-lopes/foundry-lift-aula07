// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/LiftAMMLP.sol";
import "../src/Token.sol";

contract LiftAMMLPTest is Test {
    Token public tokenA;
    Token public tokenB;
    LiftAMMLP public liftAmm;
    address public owner = vm.addr(1);

    // Criando contrato
    function setUp() public {
        // Criando label pra facilitar debug caso necessário
        vm.label(owner, "Owner");
        // Ativando a conta owner pra dar deploy nos contratos
        vm.startPrank(owner);
        tokenA = new Token("TokenA", "TKA");
        tokenB = new Token("TokenB", "TKB");
        liftAmm = new LiftAMMLP(address(tokenA), address(tokenB));
        // Daremos o máximo possível de Ether pra essa conta
        vm.deal(owner, Test.UINT256_MAX);
    }

    // Testando endereços dos tokens do LiftAMM
    function test00LiftAMMTokenAddresses() public {
        assertEq(liftAmm.tokenA(), address(tokenA));
        assertEq(liftAmm.tokenB(), address(tokenB));
    }

    // Testando addLiquidity LiftAMM
    function test00LiftAMMAddLiquidity() public {
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

    // Testando removeLiquidity LiftAMM
    function test00LiftAMMRemoveLiquidity() public {
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

    // Testando Swap LiftAMM
    function test00LiftAMMSwap() public {
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

        assertEq(amountOut, 90909090909090910);
    }

    // Testando SwapWithSlippage LiftAMM
    function test01LiftAMMSuccessSwapWithSlippage() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(liftAmm), amountA);
        tokenB.approve(address(liftAmm), amountB);
        liftAmm.addLiquidity(amountA, amountB);

        uint256 amountIn = 1 ether;
        tokenB.approve(address(liftAmm), amountIn);

        uint256 amountOutPrev = 90909090909090910;
        uint256 amountOutMin = (amountOutPrev * 95) / 100;
        liftAmm.swapWithSlippage(address(tokenB), amountIn, amountOutMin);

        uint256 ammTokenABalance = tokenA.balanceOf(address(liftAmm));
        uint256 amountOut = amountA - ammTokenABalance;

        assertGe(amountOut, amountOutMin);
    }

    function test01LiftAMMFailSwapWithSlippage() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(liftAmm), amountA);
        tokenB.approve(address(liftAmm), amountB);
        liftAmm.addLiquidity(amountA, amountB);

        uint256 amountIn = 1 ether;
        tokenB.approve(address(liftAmm), amountIn);

        uint256 amountOutPrev = 90909090909090910;
        vm.expectRevert("Slippage Insuficiente");
        liftAmm.swapWithSlippage(address(tokenB), amountIn, amountOutPrev + 1);
    }

    function test02LiftAMMSuccessSwapWithDeadLine() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(liftAmm), amountA);
        tokenB.approve(address(liftAmm), amountB);
        liftAmm.addLiquidity(amountA, amountB);

        uint256 amountIn = 1 ether;
        tokenB.approve(address(liftAmm), amountIn);
        uint256 timestamp = block.timestamp;
        uint256 delay = 5 minutes;
        liftAmm.swapWithDeadline(address(tokenB), amountIn, timestamp + delay);

        uint256 ammTokenABalance = tokenA.balanceOf(address(liftAmm));
        uint256 amountOut = amountA - ammTokenABalance;

        assertEq(amountOut, 90909090909090910);
    }

    function test02LiftAMMFailSwapWithDeadLine() public {
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
        vm.expectRevert("EXPIRADO");
        liftAmm.swapWithDeadline(address(tokenB), amountIn, timestamp + delay);
    }

    function test03LiftAMMSwapWithFee() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(liftAmm), amountA);
        tokenB.approve(address(liftAmm), amountB);
        liftAmm.addLiquidity(amountA, amountB);

        uint256 amountIn = 1 ether;
        tokenB.approve(address(liftAmm), amountIn);
        liftAmm.swapWithFee(address(tokenB), amountIn);

        uint256 ammTokenABalance = tokenA.balanceOf(address(liftAmm));
        uint256 amountOut = amountA - ammTokenABalance;

        assertEq(amountOut, 90636363636363637);
    }

    receive() external payable {}
}
