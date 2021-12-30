//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

interface IERC1155NFCT is IERC1155MetadataURI {
    function setEncryptedCode(uint256 id, bytes memory _code) external;
    function runEncryptedCode(uint256 id, string memory _abiSignature, bytes memory _key, string memory arg1, string memory arg2) external;
    function getResults(uint256 id) external returns (bytes memory results);
}

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract NFCT is ERC1155, IERC1155NFCT {
    mapping(uint256 => address) private _proxyAddresses;
    mapping(uint256 => bytes) private _encryptedCodes;
    mapping(uint256 => bytes) private _results;

    constructor() ERC1155("https://dev.null/api/url_for_/{id}/not_yet_set.json") {
        _mint(msg.sender, 1, 10, "https://dev.null/api/url_for_/{id}/not_yet_set.json");
    }
    
    function setEncryptedCode(uint256 id, bytes memory code) external override {
        _encryptedCodes[id] = code;
    }

    function create(bytes memory code) internal returns (address addr){
        assembly {
            addr := create(0,add(code,0x20), mload(code))
        }
    }

    function createMinimalProxy(address implementation) internal returns (address result) {
        bytes20 implementationBytes = bytes20(implementation);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), implementationBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }

    function runEncryptedCode(uint256 id, string memory abiSignature, bytes memory key, string memory arg1, string memory arg2) override external {
        bytes memory subContractCode = encryptDecrypt(_encryptedCodes[id], key);
        address subContractAddress = create(subContractCode);
        _proxyAddresses[id] = createMinimalProxy(subContractAddress);
        (bool success, bytes memory data) = _proxyAddresses[id].delegatecall(abi.encodeWithSignature(abiSignature, arg1, arg2));
        if (success) {
            _results[id] = data;
        }
    }

    function getResults(uint256 id) external override view returns (bytes memory) {
        return _results[id];
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

    // Purely an example of what one can do with the results; in this case, use them as the NFT's new URI.
    function uri(uint256 id) public view virtual override(ERC1155, IERC1155MetadataURI) returns (string memory) {
        if (_results[id].length > 0) {
            return abi.decode(_results[id], (string));
        }
        return super.uri(id);
    }
}
