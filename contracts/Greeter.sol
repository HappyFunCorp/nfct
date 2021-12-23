//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Adder {
    function add(uint a, uint b) public returns (uint){
        return a+b;
    }
}

contract Greeter {
    string private greeting;
    address private adderAddress;
    string private abiSignature;

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
    function createAdder(string memory _abiSignature) public {
        abiSignature = _abiSignature;
        console.log("Creating adder");
        bytes memory code = hex"606060405234610000575b60ad806100186000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063771602f714603c575b6000565b34600057605d60048080359060200190919080359060200190919050506073565b6040518082815260200191505060405180910390f35b600081830190505b929150505600a165627a7a723058205d7bec00c6d410f7ea2a3b03112b597bb3ef544439889ecc1294a77b85eab15e0029";
        adderAddress = create(code);
        console.log("created", adderAddress);
    }

    function setGreeting(string memory _greeting) public {
        console.log("adder address", adderAddress);
        (bool success, bytes memory data) = adderAddress.call(abi.encodeWithSignature(abiSignature,1,2));
        console.log("call success", success);
        uint256 resultVal = abi.decode(data, (uint256));
        greeting = append(_greeting, " ");
        greeting = append(greeting, uint2str(resultVal));
    }

    function append(string memory a, string memory b) public pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
