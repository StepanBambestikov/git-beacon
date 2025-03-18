// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "../src/git_beacon.sol";
import "../test/CounterExamples.sol";

contract DeployGitBeacon is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        CounterV1 counterV1 = new CounterV1(1);
        GitBeacon gitBeacon = new GitBeacon(address(counterV1));

        BeaconProxy proxy = new BeaconProxy(
            address(gitBeacon.beacon()),
            abi.encodeWithSignature("initialize(int256)", 1)
        );

        console.log("CounterV1 implementation deployed at:", address(counterV1));
        console.log("GitBeacon deployed at:", address(gitBeacon));
        console.log("Proxy deployed at:", address(proxy));
        
        vm.stopBroadcast();
    }
}

contract DeployNewImplementation is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address gitBeaconAddress = vm.envAddress("GIT_BEACON_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
      
        CounterV2 counterV2 = new CounterV2(1);
        GitBeacon gitBeacon = GitBeacon(gitBeaconAddress);
        
        gitBeacon.upgradeTo(address(counterV2));
        
        console.log("CounterV2 implementation deployed at:", address(counterV2));
        console.log("GitBeacon updated to implementation:", gitBeacon.getCurrentVersion());
        
        vm.stopBroadcast();
    }
}

contract RollbackImplementation is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address gitBeaconAddress = vm.envAddress("GIT_BEACON_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        GitBeacon gitBeacon = GitBeacon(gitBeaconAddress);
        gitBeacon.rollbackTo();
        
        console.log("GitBeacon rolled back to implementation:", gitBeacon.getCurrentVersion());
        
        vm.stopBroadcast();
    }
}