//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

interface IERC1155NFCT is IERC1155MetadataURI {
    function setEncryptedCode(bytes memory _code) external;
    function runEncryptedCode(string memory _abiSignature, bytes memory _key, string memory arg1, string memory arg2) external;
    function getResults() external returns (bytes memory results);
    function getResultsAsString() external returns (string memory results);
}

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract NFCT is ERC1155, IERC1155NFCT {
    address private proxyAddress;
    bytes private encryptedCode;
    bytes private results;

    constructor() ERC1155("") {
        _mint(msg.sender, 1, 1, "");
    }
    
    function setEncryptedCode(bytes memory _code) external override {
        encryptedCode = _code;
    }

    function create(bytes memory code) internal returns (address addr){
        assembly {
            addr := create(0,add(code,0x20), mload(code))
        }
    }

    function createMinimalProxy(address _implementation) internal returns (address result) {
        bytes20 implementationBytes = bytes20(_implementation);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), implementationBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }

    function runEncryptedCode(string memory _abiSignature, bytes memory _key, string memory _arg1, string memory _arg2) override external {
        bytes memory subContractCode = encryptDecrypt(encryptedCode, _key);
        address subContractAddress = create(subContractCode);
        proxyAddress = createMinimalProxy(subContractAddress);
        (bool success, bytes memory data) = proxyAddress.delegatecall(abi.encodeWithSignature(_abiSignature, _arg1, _arg2));
        if (success) {
            results = data;
        }
    }

    function getResults() external override view returns (bytes memory) {
        return results;
    }

    function getResultsAsString() external override view returns (string memory) {
        return abi.decode(results, (string));
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
