//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Greeter {
    string private greeting;
    address private delegateAddress;

    constructor(string memory _greeting, address _address) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
        delegateAddress = _address;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setDelegateAddress(address _newAddress) public {
        // TODO ensure only owner can do this obvs
        console.log("Setting new delegate address to", _newAddress);
        delegateAddress = _newAddress;
    }

    function setGreeting(string memory _greeting) public {
        (bool success, bytes memory result) = delegateAddress.delegatecall(abi.encodeWithSignature("setGreeting(string)", _greeting));
        console.log("delegate call success", success);
        console.log("delegate call result", string(result));
    }
}
