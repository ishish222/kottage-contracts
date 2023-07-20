// SPDX-License-Identifier: MIT
// @author ts@ishish.io

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

/**
 * @title ERC721 Mergeable Token
 * @dev A set of mergeable tokens can be merged into a new Token.
 */
abstract contract ERC721Mergeable is Context, ERC721, ERC721Burnable {

    event TokensMerged(uint256[]);

    function _isBatchMergeable(uint256[] calldata tokensIds) public virtual returns (bool);

    function _merge(uint256[] calldata tokenIds) internal virtual returns (uint256);

    function merge(uint256[] calldata tokenIds) public virtual returns (uint256){
        
        uint256 mergedId;

        require(_isBatchMergeable(tokenIds), "ERC721Mergeable: the token batch is not mergeable");
        
        mergedId = _merge(tokenIds);

        for (uint256 i; i < tokenIds.length; i++)
        {
            require(_isApprovedOrOwner(_msgSender(), tokenIds[i]), "ERC721: caller is not token owner or approved");
            burn(tokenIds[i]);
        }

        emit TokensMerged(tokenIds);
        return mergedId;
    }
}
