//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract CodeCaller {
    string private greeting;
    address private subContractAddress;
    string private subContractAbiSignature;

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
    function createSubContract(bytes memory _code, string memory _abiSignature) public {
        subContractAbiSignature = _abiSignature;
        console.log("Creating subcontract");
        subContractAddress = create(_code);
        console.log("created", subContractAddress);
    }

    function setGreeting(string memory arg1, string memory arg2) public {
        console.log("adder address", subContractAddress);
        (bool success, bytes memory data) = subContractAddress.call(abi.encodeWithSignature(subContractAbiSignature, arg1, arg2));
        console.log("call success", success);
        greeting = abi.decode(data, (string));
        console.log("new greeting", greeting);
    }
}
