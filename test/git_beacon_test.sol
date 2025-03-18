// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Test.sol";
import "test/CounterExamples.sol";
import "src/git_beacon.sol";

contract GitBeaconTest is Test {
    address public owner;
    address public user1;

    address counter1;
    address counter2;
    address counter3;

    int public constant value = 1;

    GitBeacon beacon;
    address proxy;

    function setUp() public {
      owner = address(this);
      user1 = address(0x1);

      counter1 = address(new CounterV1(value));
      counter2 = address(new CounterV2(value));
      counter3 = address(new CounterV3(value));

      beacon = new GitBeacon(counter1);

      proxy = address(new BeaconProxy(
        address(beacon.beacon()),
        ""
      ));
    }

    function testInitialState() public view {
      assertEq(beacon.getCurrentVersion(), address(counter1));
      assertEq(beacon.getVersionHistoryCount(), 1);
    }

    function testOwnableRole() public {
      vm.prank(user1);
      vm.expectRevert();
      beacon.upgradeTo(counter2);
      vm.stopPrank();
    }

    function testSameImplementationError() public {
      vm.prank(owner);
      vm.expectRevert();
      beacon.upgradeTo(counter1);
      vm.stopPrank();
    }

    function testUpgradeToZeroAddress() public {
      vm.prank(owner);
      vm.expectRevert();
      beacon.upgradeTo(address(0));
      vm.stopPrank();
    }

    function testUpgradeTo() public {
      vm.prank(owner);
      assertEq(CounterV1(proxy).get(), 1);
      beacon.upgradeTo(counter2);
      assertEq(beacon.getVersionHistoryCount(), 2);
      assertEq(beacon.getCurrentVersion(), address(counter2));

      assertEq(CounterV2(proxy).get(), 2);
      vm.stopPrank();
    }

    function testRollbackTo() public {
      vm.prank(owner);
      beacon.upgradeTo(counter2);
      beacon.rollbackTo();
      assertEq(beacon.getVersionHistoryCount(), 2);
      assertEq(beacon.getCurrentVersion(), address(counter1));

      assertEq(CounterV1(proxy).get(), 1);
      vm.stopPrank();
    }

    function testUpgradeIncOutOfRange() public {
      vm.prank(owner);
      vm.expectRevert();
      beacon.updateInc();
      vm.stopPrank();
    }

    function testRollbackToOutOfRange() public {
      vm.prank(owner);
      beacon.upgradeTo(counter2);
      beacon.rollbackTo();
      vm.expectRevert();
      beacon.rollbackTo();
      vm.stopPrank();
    }

    function testAverageWorkWith() public {
      vm.prank(owner);
      beacon.upgradeTo(counter2);
      beacon.upgradeTo(counter3);
      assertEq(beacon.getVersionHistoryCount(), 3);
      assertEq(beacon.getCurrentVersion(), address(counter3));

      assertEq(CounterV3(proxy).get(), 3);
      beacon.rollbackTo();
      assertEq(CounterV2(proxy).get(), 2);
      beacon.rollbackTo();
      assertEq(CounterV1(proxy).get(), 1);

      beacon.updateInc();
      assertEq(CounterV2(proxy).get(), 2);
      beacon.updateInc();
      assertEq(CounterV3(proxy).get(), 3);

      vm.stopPrank();
    }
}
