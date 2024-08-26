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
    assertEq(fundMe.getOwner(), msg.sender);
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
  
  
  function testWithdrawWithASingleFunder() public funded {
    // Arrange
    // balance of owner
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;
    
    // Act
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();
    
    // assert
    uint256 endingOwnerBalance = fundMe.getOwner().balance;
    uint256 endingFundMeBalance = address(fundMe).balance;
    
    assertEq(endingFundMeBalance, 0);
    
    assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    
  }
  
  function testWithdrawFromMultipleFunders() public funded {
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;
    
    // to avoid the sending fund at 0 address set starting at 1.
    for( uint160 i = startingFunderIndex; i < numberOfFunders ;i++) {
      // vm prank new address.
      // vm deal add balance.
      
      hoax(address(i), SEND_VALUE);
      fundMe.fund{value: SEND_VALUE}();
      // fund the fundMe.
    }
    
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;
    console.log(startingFundMeBalance);
    // start and stop prank.
    vm.startPrank(fundMe.getOwner());
    fundMe.withdraw();
    vm.stopPrank();
  
    assertEq(address(fundMe).balance, 0);
    
    assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    
  }
  
  
}