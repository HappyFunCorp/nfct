//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Greeter {
    string private greeting;
    address private adderAddress;

    constructor(string memory _greeting) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function create(bytes memory code) internal returns (address addr){
        assembly {
            addr := create(0,add(code,0x20), mload(code))
        }
    }
    function createAdder() public {
        console.log("Creating adder");
        bytes memory code = hex"606060405234610000575b60ad806100186000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063771602f714603c575b6000565b34600057605d60048080359060200190919080359060200190919050506073565b6040518082815260200191505060405180910390f35b600081830190505b929150505600a165627a7a723058205d7bec00c6d410f7ea2a3b03112b597bb3ef544439889ecc1294a77b85eab15e0029";
        adderAddress = create(code);
        console.log("created", adderAddress);
    }

    function setGreeting(string memory _greeting) public {
        console.log("adder address", adderAddress);
        string memory newGreeting = append(_greeting, " ");
        (bool success, bytes memory result) = adderAddress.call(abi.encode("add(uint256, uint256)", 1, 2));
        console.log("call success", success);
        console.log("call result", string(result));
        newGreeting = append(newGreeting, string(result));
        console.log("Changing greeting from '%s' to '%s'", greeting, newGreeting);
    }

    function append(string memory a, string memory b) public pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }
}
