//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// obvious TODO: restrict calls to owner of NFCT

contract CodeCaller {
    string private greeting;
    bytes private encryptedCode;

    constructor(string memory _greeting) {
        console.log("Deploying a CodeCaller with greeting:", _greeting);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setEncryptedCode(bytes memory _code) public {
        console.log("setting encrypted code, lengtH:", _code.length);
        encryptedCode = _code;
    }

    function create(bytes memory code) internal returns (address addr){
        assembly {
            addr := create(0,add(code,0x20), mload(code))
        }
    }

    function callCode(string memory _abiSignature, bytes memory _key, string memory arg1, string memory arg2) public {
        console.log("Creating subcontract", _abiSignature);
        bytes memory subContractCode = encryptDecrypt(encryptedCode, _key);
        address subContractAddress = create(subContractCode);
        console.log("created", subContractAddress);
        (bool success, bytes memory data) = subContractAddress.call(abi.encodeWithSignature(_abiSignature, arg1, arg2));
        console.log("call success", success);
        greeting = abi.decode(data, (string));
        console.log("new greeting", greeting);
    }

    function encryptDecrypt (bytes memory data, bytes memory key) public pure returns (bytes memory result) {
        uint256 length = data.length;

        assembly {
            result := mload (0x40)
            mstore (0x40, add (add (result, length), 32))
            mstore (result, length)
        }

        for (uint i = 0; i < length; i += 32) {
            bytes32 hash = keccak256 (abi.encodePacked (key, i));
            bytes32 chunk;
            assembly {
                chunk := mload (add (data, add (i, 32)))
            }
            chunk ^= hash;
            assembly {
                mstore (add (result, add (i, 32)), chunk)
            }
        }
    }
}