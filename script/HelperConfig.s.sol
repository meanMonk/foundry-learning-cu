// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
// 1. deploy local mocks when we are on local anvil chain.
// 2. keep track of contract address across different chains
// Mainnet ETH/USD
// Sepolia ETH/USD

import {Script} from 'forge-std/Script.sol';

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
    } else {
      activeConfig = getAnvilEthConfig();
    }
  }
  
  function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
    NetworkConfig memory networkConfig = NetworkConfig({
      priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    });
    return networkConfig;
  }
  
  function getAnvilEthConfig() public pure returns(NetworkConfig memory) {
    
  }
   
}