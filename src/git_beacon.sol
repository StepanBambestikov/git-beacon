// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GitBeacon is Ownable {
    UpgradeableBeacon public beacon;
    address[] public versionHistory;
    uint public currentVersion;
    
    event ImplementationAdded(address implementation);
    event ImplementationSwitched(address toAddress);
    
    constructor(address initialImplementation) Ownable(msg.sender) {
        beacon = new UpgradeableBeacon(initialImplementation, msg.sender);
        beacon.transferOwnership(address(this));
        upgradeTo(initialImplementation);
        currentVersion = 0;
    }
    
    function upgradeTo(address implementation) public onlyOwner {
        require(implementation != address(0), "Invalid implementation address");
        versionHistory.push(implementation);
        currentVersion = versionHistory.length - 1;
        emit ImplementationAdded(implementation);
    }

    function updateInc() public onlyOwner {
        require(
          currentVersion < versionHistory.length - 1,
          "Already Highest version"
        );
        currentVersion++;
        beacon.upgradeTo(versionHistory[currentVersion]);
        emit ImplementationSwitched(versionHistory[currentVersion]);
    }

    function rollbackTo() public onlyOwner {
        require(
          currentVersion > 0,
          "Already lowest version"
        );
        currentVersion--;
        beacon.upgradeTo(versionHistory[currentVersion]);
        emit ImplementationSwitched(versionHistory[currentVersion]);
    }
    
    function getCurrentVersion() public view returns (address) {
        return beacon.implementation();
    }
    
    function getVersionHistory() public view returns (address[] memory) {
        return versionHistory;
    }
    
    function getVersionHistoryCount() public view returns (uint256) {
        return versionHistory.length;
    }
}
