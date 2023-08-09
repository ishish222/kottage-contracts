// SPDX-License-Identifier: MIT
// @author ts@ishish.io

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./KottageToken.sol";

contract KottageContractFactory is Context, Ownable {

    address[] public allContracts;
    mapping(address => address[]) public addr2Contracts;

    event KottageContractCreated(address addr, address owner, string name, string symbol);
    
    function addr2ContractsLength(address addr) public view returns (uint256) {
        return addr2Contracts[addr].length;
    }

    function createKottageContract(string memory name, string memory symbol, string memory uri) external returns (address) {
        address token;
        KottageToken KToken;

        KToken = new KottageToken(name, symbol, uri);
        KToken.transferOwnership(_msgSender());

        token = address(KToken);
        addr2Contracts[_msgSender()].push(token);

        emit KottageContractCreated(token, KToken.owner(), name, symbol);
        return token;
    }

    function getContractByAddrIndex(address addr, uint index) public view returns (address) {
        return addr2Contracts[addr][index];
    }

    function totalContracts() public view returns (uint256) {
        return allContracts.length;        
    }

}
