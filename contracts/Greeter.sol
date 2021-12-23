//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Greeter {
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

    function setGreeting(string memory _greeting, uint arg1, uint arg2) public {
        console.log("adder address", subContractAddress);
        (bool success, bytes memory data) = subContractAddress.call(abi.encodeWithSignature(subContractAbiSignature, arg1, arg2));
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
