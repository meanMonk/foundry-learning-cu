// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from '../src/FundMe.sol';
import {DeployFundMe} from '../script/DeployFundMe.s.sol';

contract FundMeTest is Test {
  FundMe fundMe;
  
  function setUp() external {
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
  } 
  
  function testMinimumDollarIsFive() public view {
    assertEq(fundMe.MINIMUM_USD(), 5e18);
  }
  
  function testOwnerIsMsgOwner() public view {
    assertEq(fundMe.i_owner(), msg.sender);
  }
  
  // This will fail as we have hardcoded contract address for sepolia.
  // what can we do 
  // 1. unit - testing specific part of code. 
  // 2. integration - testing how our code works with other parts of our code.
  // 3. forked - testing code on simulated real environment.
  // 4. staging - testing on real env which is not prod.
  
  function testPriceFeedVersionIsAccurate() public view {
    uint256 version = fundMe.getVersion();
    assertEq(version, 4);
  }
  
  // Modular deployments
  // Modular tests
}