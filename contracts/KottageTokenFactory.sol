// SPDX-License-Identifier: MIT
// @author ts@ishish.io

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./KottageToken.sol";

contract KottageTokenFactory is Context, Ownable {

    mapping(address => address[]) public addr2Tokens;

    event KottageTokenCreated(address addr, address owner, string name, string symbol);
    
    function addr2TokensLength(address addr) public view returns (uint256) {
        return addr2Tokens[addr].length;
    }

    function createKottageToken(string memory name, string memory symbol, string memory uri) external returns (address) {
        address token;
        KottageToken KToken;

        KToken = new KottageToken(name, symbol, uri);
        KToken.transferOwnership(_msgSender());

        token = address(KToken);
        addr2Tokens[_msgSender()].push(token);

        emit KottageTokenCreated(token, KToken.owner(), name, symbol);
        return token;
    }
    function getAddr2TokenByIndex(address addr, uint index) public view returns (address) {
        return addr2Tokens[addr][index];
    }
}
