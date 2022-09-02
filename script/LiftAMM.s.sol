// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/LiftAMM.sol";
import "../src/Token.sol";

contract DeployLiftAMM is Script {
    Token public tokenA;
    Token public tokenB;
    LiftAMM public liftAmm;

    function run() external {
        vm.startBroadcast();

        tokenA = new Token("TokenA", "TKA");
        tokenB = new Token("TokenB", "TKB");
        liftAmm = new LiftAMM(address(tokenA), address(tokenB));

        vm.stopBroadcast();
    }
}
