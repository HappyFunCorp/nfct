//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract CodeCaller {
    string private _greeting;
    bytes private _encryptedCode;
    address private _subContractAddress;

    constructor(string memory greeting) {
        console.log("Deploying a CodeCaller with greeting:", greeting);
        _greeting = greeting;
    }

    function greet() public view returns (string memory) {
        return _greeting;
    }

    function setEncryptedCode(bytes memory code) public {
        console.log("setting encrypted code, lengtH:", code.length);
        _encryptedCode = code;
        _subContractAddress = address(0);
    }

    function create(bytes memory code) internal returns (address addr){
        assembly {
            addr := create(0,add(code,0x20), mload(code))
        }
    }

    function callCode(bytes memory key, string memory abiSignature, string[] memory args) public {

        // Decrypt and deploy
        console.log("Calling subcontract which hopefully has signature", abiSignature);
        if (_subContractAddress== address(0)) {
            bytes memory subContractCode = encryptDecrypt(_encryptedCode, key); // decrypt
            _subContractAddress = create(subContractCode); // deploy
            console.log("created", _subContractAddress);
        }

        // Run 
        bytes memory signature;
        if (args.length==0) {
           signature  = abi.encodeWithSignature(abiSignature);
        }
        if (args.length==1) {
            signature  = abi.encodeWithSignature(abiSignature, args[0]);
        }
        if (args.length==2) {
            signature  = abi.encodeWithSignature(abiSignature, args[0], args[1]);
        }
        if (args.length==3) {
            signature  = abi.encodeWithSignature(abiSignature, args[0], args[1], args[2]);
        }
        (bool success, bytes memory data) = _subContractAddress.call(signature);
        console.log("call success", success);

        // Pass back the data
        if (data.length == 0) {
            console.log("no data");
        } else {
            _greeting = abi.decode(data, (string));
            console.log("new greeting", _greeting);
        }
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
