// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CounterV1 {
    int value;
    constructor(int _value) {
      value = _value;
    }

    function initialize(int _value) public {
      value = _value;
    }

    function get() public view returns(int){
      return value;
    }
}

contract CounterV2 {
    int value;
    constructor(int _value) {
      value = _value;
    }

    function initialize(int _value) public {
      value = _value;
    }

    function get() public view returns(int){
      return value * 2;
    }

    function inc() public{
      value++;
    }
}

contract CounterV3 {
    int value;
    constructor(int _value) {
      value = _value;
    }

    function initialize(int _value) public {
      value = _value;
    }

    function get() public view returns(int){
      return value * 3;
    }

    function inc() public{
      value++;
    }

    function dec() public{
      value--;
    }
}
