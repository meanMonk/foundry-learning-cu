// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from '../src/FundMe.sol';
import {DeployFundMe} from '../script/DeployFundMe.s.sol';

contract FundMeTest is Test {
  FundMe fundMe;
  
  address ALICE = makeAddr("alice");
  uint256 constant SEND_VALUE= 0.1 ether;
  uint256 constant STARTING_BALANCE = 10 ether; 
  
  // setup gets run on each unit tests.
  function setUp() external {
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
    vm.deal(ALICE, STARTING_BALANCE);
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
  
  function testFundFailsWithoutEnoughETH() public {
    vm.expectRevert();
    fundMe.fund();
  }
  
  function testFundUpdatesFundedDataStructure() public {
    vm.prank(ALICE); // next trx will be send by user ALICE
    
    fundMe.fund{value: SEND_VALUE}();
    uint256 amountFunded = fundMe.getAddressToAmountFunded(ALICE);
    
    assertEq(amountFunded, SEND_VALUE);
  }
  
  // prepare modifier for duplicated code 
  // can use modifier to fund in any test we want
  // solidity best practices
  modifier funded {
    vm.prank(ALICE);
    fundMe.fund{value: SEND_VALUE}();
    _;
  }
  
  function testAddsFunderToArrayOfFunders() public funded {
    address funder = fundMe.getFunderAtIndex(0);
    assertEq(ALICE, funder);
  }
  
  function testOnlyOnwerCanWithdraw() public funded {
    vm.expectRevert();
    vm.prank(ALICE); // user is not the owner of contract.
    
    fundMe.withdraw(); 
  }
  
}