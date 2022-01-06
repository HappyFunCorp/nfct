//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

interface IERC1155NFCT is IERC1155MetadataURI {
    function commitEncryptedCode(uint256 tokenId, bytes memory code) external;
    function decryptAndDeployCode(uint256 tokenId, bytes memory key) external;
    function runCode(uint256 tokenId, string memory abiSignature, string[] memory args) external;
    function getResults(uint256 tokenId) external returns (bytes memory results);
    // if it were really important to have an atomic deployAndRun method, one could be added, but seems no need
}

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract NFCT is ERC1155, IERC1155NFCT {
    mapping(uint256 => bytes) private _encryptedCodes;
    mapping(uint256 => address) private _subContractAddresses;
    mapping(uint256 => bytes) private _results;

    uint256 public constant WORLDS_FIRST_NFCT = 1;
    uint256 public constant WORLDS_SECOND_NFCT = 2;

    constructor() ERC1155("https://dev.null/api/url_for_/{id}/not_yet_set.json") {
        _mint(msg.sender, 1, WORLDS_FIRST_NFCT, ""); // there's only one World's First
        _mint(msg.sender, 2, WORLDS_SECOND_NFCT, ""); // but there are two World's Second
    }
    
    function commitEncryptedCode(uint256 tokenId, bytes memory code) external override {
        require(balanceOf(msg.sender, tokenId) > 0);
        _encryptedCodes[tokenId] = code;
    }

    function decryptAndDeployCode(uint256 tokenId, bytes memory key) override public {
        require(balanceOf(msg.sender, tokenId) > 0);
        bytes memory subContractCode = encryptDecrypt(_encryptedCodes[tokenId], key);
        _subContractAddresses[tokenId] = createContract(subContractCode);
    }

    /*
     * Conceivably could persist data across different code deployments, using a minimal proxy and delegatecall:
     * https://eips.ethereum.org/EIPS/eip-1167
     * https://docs.soliditylang.org/en/v0.8.10/introduction-to-smart-contracts.html#delegatecall-callcode-and-libraries
     * https://stackoverflow.com/questions/67464855/create-a-contract-externally
     * Optional: maintain a different set of "runners" vs. "owners"
     * e.g. require(_codeRunner[tokenId] == msg.sender);
    */
    function runCode(uint256 tokenId, string memory abiSignature, string[] memory args) override public {
        require(balanceOf(msg.sender, tokenId) > 0); // but again note other possibilites exist...
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
        (bool success, bytes memory data) = _subContractAddresses[tokenId].call(signature);
        if (success) {
            _results[tokenId] = data;
        }
    }

    function getResults(uint256 tokenId) external override view returns (bytes memory) {
        return _results[tokenId];
    }

    // A very basic example of using the computed results; in this case, as this NFT's new URI.
    function uri(uint256 tokenId) public view virtual override(ERC1155, IERC1155MetadataURI) returns (string memory) {
        if (_results[tokenId].length > 0) {
            return abi.decode(_results[tokenId], (string));
        }
        return super.uri(tokenId);
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

    function createContract(bytes memory code) internal returns (address addr){
        assembly {
            addr := create(0,add(code,0x20), mload(code))
        }
    }

}
