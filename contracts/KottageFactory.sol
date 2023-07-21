// SPDX-License-Identifier: MIT
// @author ts@ishish.io

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./KottageERC721.sol";

contract KottageTokenFactory is Context, Ownable {

    event KottageTokenCreated(address addr, string name, string symbol);

    function createKottageToken(string memory name, string memory symbol) external returns (address) {
        address token;
        KottageToken KToken;

        KToken = new KottageToken(name, symbol);
        KToken.transferOwnership(_msgSender());

        token = address(KToken);

        emit KottageTokenCreated(token, name, symbol);
        return token;
    }
}