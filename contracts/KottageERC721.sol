// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@quant-finance/solidity-datetime/contracts/DateTime.sol";
import "./ERC721/ERC721Mergeable.sol";

contract KottageToken is ERC721Mergeable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    struct rentalPeriod {
        uint256 start;
        uint256 end;
    }

    mapping(uint256 => rentalPeriod) public rentalPeriods;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        
    }

    function _isBatchMergeable(uint256[] calldata tokenIds) public view override {
        /*confirm that the dates are sequential */ 

        for (uint256 i; i < tokenIds.length-1; i++)
        {
            // check that token has been actually issued (necessary?)
            // check that token has not been burned (necessary?)
            
            require(_isApprovedOrOwner(_msgSender(), tokenIds[i]), "ERC721: caller is not token owner or approved");
            
            // check that there is smooth transition between a batch of tokens
            require((DateTime.diffSeconds(rentalPeriods[i].end, rentalPeriods[i+1].start) == 0), "KottageToken: tokens in the batch are not sequential");
        }
    }

    function _merge(uint256[] calldata tokenIds, string memory uri) internal override
    {
        uint256 mergedStart = rentalPeriods[tokenIds[0]].start;                   // retrieve date from metadata
        uint256 mergedEnd = rentalPeriods[tokenIds[tokenIds.length-1]].end;
        

        safeMint(_msgSender(), uri, mergedStart, mergedEnd);
    }

    function safeMint(address to, string memory uri, uint256 start, uint256 end) public onlyOwner {
        // check for overbooking
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(to, tokenId);
        
        rentalPeriods[tokenId].start = start;
        rentalPeriods[tokenId].end = end;
        
        _setTokenURI(tokenId, uri);
    }

}