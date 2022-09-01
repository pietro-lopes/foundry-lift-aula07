// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/LiftAMMLP.sol";
import "../src/Token.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract LiftAMMLPTest is Test {
    Token public tokenA;
    Token public tokenB;
    IUniswapV2Router02 public router =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    LiftAMMLP public liftAmm;
    address public owner = vm.addr(1);
    uint256 public constant MIN_LIQ = 10**3;

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

    // Testando addLiquidity LiftAMM
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
        tokenB.approve(address(liftAmm), amountIn * 2);
        uint256 amountOut;
        amountOut = liftAmm.swapWithFee(address(tokenB), amountIn);

        // uint256 ammTokenABalance = tokenA.balanceOf(address(liftAmm));

        assertEq(amountOut, 90661089388014914);

        amountOut = liftAmm.swapWithFee(address(tokenB), amountIn);
        // ammTokenABalance = tokenA.balanceOf(address(liftAmm));
        // amountOut = amountA - ammTokenABalance;
        assertEq(amountOut, 75569800273414115);
    }

    function test01UniswapLiftAMMAddLiquidity() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(router), amountA);
        tokenB.approve(address(router), amountB);
        uint256 time = block.timestamp + 5 minutes;
        uint256 liq;
        (, , liq) = router.addLiquidity(
            address(tokenA),
            address(tokenB),
            amountA,
            amountB,
            0,
            0,
            address(owner),
            time
        );

        assertEq(liq, 3162277660168379331 - MIN_LIQ);
    }

    function test01UniswapLiftAMMSwap() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 10 ether;

        tokenA.approve(address(router), amountA);
        tokenB.approve(address(router), amountB);
        uint256 time = block.timestamp + 5 minutes;
        uint256 liq;
        (, , liq) = router.addLiquidity(
            address(tokenA),
            address(tokenB),
            amountA,
            amountB,
            0,
            0,
            address(owner),
            time
        );

        assertEq(liq, 3162277660168379331 - MIN_LIQ);

        uint256 amountIn = 1 ether;
        tokenB.approve(address(router), amountIn * 2);
        address[] memory path = new address[](2);
        path[0] = address(tokenB);
        path[1] = address(tokenA);
        uint256[] memory amounts;
        amounts = router.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(owner),
            time
        );
        assertEq(amounts[1], 90661089388014913);

        amounts = router.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(owner),
            time
        );
        assertEq(amounts[1], 75569800273414114);
        // uint256 ammTokenABalance = tokenA.balanceOf(address(owner));
        // uint256 amountOut = amountA - ammTokenABalance;
    }

    // function test01UniswapLiftAMMSwapWithFee() public {
    //     uint256 amountA = 1 ether;
    //     uint256 amountB = 10 ether;

    //     tokenA.approve(address(router), amountA);
    //     tokenB.approve(address(router), amountB);
    //     uint256 time = block.timestamp + 5 minutes;
    //     router.addLiquidity(address(tokenA),address(tokenB), amountA, amountB, 0, 0, address(owner),time);

    //     uint256 amountIn = 1 ether;
    //     tokenB.approve(address(liftAmm), amountIn);
    //     liftAmm.swapWithFee(address(tokenB), amountIn);

    //     uint256 ammTokenABalance = tokenA.balanceOf(address(liftAmm));
    //     uint256 amountOut = amountA - ammTokenABalance;

    //     assertEq(amountOut, 90636363636363637);
    // }

    receive() external payable {}
}
