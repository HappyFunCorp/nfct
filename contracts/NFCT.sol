//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

interface IERC1155NFCT is IERC1155MetadataURI {
    function setEncryptedCode(bytes memory _code) external;
    function runEncryptedCode(string memory _abiSignature, bytes memory _key, string memory arg1, string memory arg2) external;
}

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract NFCT is ERC1155, IERC1155NFCT {
    constructor() ERC1155("") {
        _mint(msg.sender, 1, 1, "");
    }
    
    function setEncryptedCode(bytes memory _code) override external {

    }
    function runEncryptedCode(string memory _abiSignature, bytes memory _key, string memory arg1, string memory arg2) override external {

    }
}
