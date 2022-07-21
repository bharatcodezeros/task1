// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract myNft is ERC721{
    uint private _tokenId;
    constructor() ERC721("codk","CDK"){

    }

    function mintNft(address recipient) public{
        _tokenId++;
        _mint(recipient,_tokenId);

    }
}


