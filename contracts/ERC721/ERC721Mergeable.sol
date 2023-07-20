// SPDX-License-Identifier: MIT
// @author ts@ishish.io

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/**
 * @title ERC721 Mergeable Token
 * @dev A set of mergeable tokens can be merged into a new Token.
 */
abstract contract ERC721Mergeable is Context, ERC721, ERC721URIStorage {

    modifier isMergeable(uint256[] calldata tokenIds)
    {
        _isBatchMergeable(tokenIds);
        _;
    }

    event TokensMerged(uint256[]);

    function _isBatchMergeable(uint256[] calldata tokenIds) public virtual;

    function _merge(uint256[] calldata tokenIds, string memory uri) internal virtual;

    function merge(uint256[] calldata tokenIds, string memory uri) public virtual isMergeable(tokenIds) {
        _merge(tokenIds, uri);

        for (uint256 i; i < tokenIds.length; i++)
        {
            require(_isApprovedOrOwner(_msgSender(), tokenIds[i]), "ERC721: caller is not token owner or approved");
            _burn(tokenIds[i]);
        }

        emit TokensMerged(tokenIds);
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
    }

}