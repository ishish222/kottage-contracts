// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@quant-finance/contracts/DateTime.sol";
import "./ERC721/ERC721Mergeable.sol";

contract KottageToken is ERC721, ERC721Mergeable, Ownable {
    using Counters for Counters.Counter;
    using DateTime for DateTime.DateTime;

    Counters.Counter private _tokenIdCounter;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        
    }

    function _isBatchMergeable(uint256[] calldata tokenIds) public override returns (bool) {
        /*confirm that the dates are sequential */ 

        for (uint256 i; i < tokenIds-1.length; i++)
        {
            require(_isApprovedOrOwner(_msgSender(), tokenIds[i]), "ERC721: caller is not token owner or approved");
            require((DateTime.diffDays(tokenIds[i], tokenIds[i+1]) == 1), "KottageToken: tokens in the batch are not sequential");
        }

    }

    function _merge(uint256[] calldata tokenIds) internal override returns (uint256)
    {
        uint startDate = tokenIds[0];                   // retrieve date from metadata
        uint endDate = tokenIds[tokenIds.length-1];

        safeMint(_msgSender());
    }

    function safeMint(address to) public onlyOwner {
        // include modifications, setting date off-chain
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}