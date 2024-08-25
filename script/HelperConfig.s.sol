// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
// 1. deploy local mocks when we are on local anvil chain.
// 2. keep track of contract address across different chains
// Mainnet ETH/USD
// Sepolia ETH/USD

import {Script} from 'forge-std/Script.sol';

import {MockV3Aggregator} from '../test/mock/MockV3Aggregator.sol';

contract HelperConfig is Script {
  // If we are on local anvil, we deploy mocks
  // otherwise grab the existings address from live chain.
  
  NetworkConfig public activeConfig;
  
  struct NetworkConfig {
    address priceFeed; // ETH/USD price feed address.
  }
  
  constructor() {
    // chain id for sepolia
    if (block.chainid == 11155111) {
      activeConfig = getSepoliaEthConfig();
    } else if (block.chainid == 1) {
      activeConfig = getMainnetEthConfig();
    } else {
      activeConfig = getAnvilEthConfig();
    }
  }
  
  function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
    NetworkConfig memory sepoliaConfig = NetworkConfig({
      priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    });
    return sepoliaConfig;
  }
  
  function getMainnetEthConfig() public pure returns(NetworkConfig memory) {
    NetworkConfig memory ethConfig = NetworkConfig({
      priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
    });
    return ethConfig;
  }
  
  function getAnvilEthConfig() public returns(NetworkConfig memory) {
    // price feed contract mock.
    // 1- deploy the mock
    // 2. return the mock address.
    // should not be pure function as we are working with vm.
    vm.startBroadcast();
    MockV3Aggregator  mockV3Agregator = new MockV3Aggregator(8, 2000e8);
    vm.stopBroadcast();
    
    NetworkConfig memory anvilConfig = NetworkConfig({
      priceFeed: address(mockV3Agregator)
    });
    
    return anvilConfig;
    
  }
   
}