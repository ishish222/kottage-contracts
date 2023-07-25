// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@quant-finance/solidity-datetime/contracts/DateTime.sol";

contract KottageToken is ERC721, Ownable, ERC721URIStorage {
    using Counters for Counters.Counter;

    string public uri;

    Counters.Counter private _tokenIdCounter;

    struct rentalPeriod {
        uint256 start;
        uint256 end;
    }

    event TokensMerged(uint256[]);
    event TokenSplit(uint256);
    event TokenMinted(uint256, uint256, uint256);
    event TokenBurned(uint256);

    mapping(uint256 => rentalPeriod) public rentalPeriods;

    constructor(string memory name_, string memory symbol_, string memory uri_) ERC721(name_, symbol_) {
        uri = uri_;        
    }
    
    modifier isMergeable(uint256[] calldata tokenIds)
    {
        _isBatchMergeable(tokenIds);
        _;
    }

    modifier isSplittable(uint256 tokenId, rentalPeriod[] calldata new_periods)
    {
        _isBatchSplittable(tokenId, new_periods);
        _;
    } 
    
    function _isBatchSplittable(uint256 tokenId, rentalPeriod[] calldata new_periods) public view {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        for (uint256 i=0; i < new_periods.length-1; i++)
        {
            // check that there is smooth transition between a batch of tokens
            require((DateTime.diffSeconds(new_periods[i].end, new_periods[i+1].start) == 0), "KottageToken: tokens in the batch are not sequential");
        }
        require(new_periods[0].start == rentalPeriods[tokenId].start, "KottageToken: Proposed rental start of sequence does not match rental start of token");
        require(new_periods[new_periods.length-1].end == rentalPeriods[tokenId].end, "KottageToken: Proposed rental end of sequence does not match rental end of token");
    }

    function _isBatchMergeable(uint256[] calldata tokenIds) public view {

        for (uint256 i=0; i < tokenIds.length-1; i++)
        {
            require(_isApprovedOrOwner(_msgSender(), tokenIds[i]), "ERC721: caller is not token owner or approved");
            
            // check that there is smooth transition between a batch of tokens
            require((DateTime.diffSeconds(rentalPeriods[tokenIds[i]].end, rentalPeriods[tokenIds[i+1]].start) == 0), "KottageToken: tokens in the batch are not sequential");
        }
        // check the ownership of the last token in the sequence
        require(_isApprovedOrOwner(_msgSender(), tokenIds[tokenIds.length-1]), "ERC721: caller is not token owner or approved");
    }

    function _merge(uint256[] calldata tokenIds) internal
    {
        uint256 mergedStart = rentalPeriods[tokenIds[0]].start;                   // retrieve date from metadata
        uint256 mergedEnd = rentalPeriods[tokenIds[tokenIds.length-1]].end;
        
        safeMint(_msgSender(), mergedStart, mergedEnd);

        for (uint256 i=0; i < tokenIds.length; i++)
        {
            _burn(tokenIds[i]);
        }
    }
    
    function merge(uint256[] calldata tokenIds) public isMergeable(tokenIds) {
        _merge(tokenIds);

        emit TokensMerged(tokenIds);
    }

    function _split(uint256 tokenId, rentalPeriod[] calldata new_rentals) internal
    {
        for (uint256 i=0; i < new_rentals.length; i++)
        {
            safeMint(_msgSender(), new_rentals[i].start, new_rentals[i].end);    
        }

        _burn(tokenId);
    }

    function split(uint256 tokenId, rentalPeriod[] calldata new_rentals) public isSplittable(tokenId, new_rentals) {
        _split(tokenId, new_rentals);

        emit TokenSplit(tokenId);
    }

    function safeMint(address to, uint256 start, uint256 end) public onlyOwner {
        // check for overbooking
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(to, tokenId);
        
        rentalPeriods[tokenId].start = start;
        rentalPeriods[tokenId].end = end;
        
        _setTokenURI(tokenId, uri);

        emit TokenMinted(tokenId, rentalPeriods[tokenId].start, rentalPeriods[tokenId].end);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
        emit TokenBurned(tokenId);
    }

}