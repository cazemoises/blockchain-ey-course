// SPDX-License-Identifier: CC-BY-4.0
pragma solidity 0.8.19;

/// @title Manages the contract owner
contract Ownable {
    address payable contractOwner;

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "only owner can perform this operation");
        _;
    }

    constructor() { 
        contractOwner = payable(msg.sender); 
    }
    
    function whoIsTheOwner() public view returns(address) {
        return contractOwner;
    }

    function changeOwner(address _newOwner) onlyOwner public returns (bool) {
        require(_newOwner != address(0x0), "only valid address");
        contractOwner = payable(_newOwner);
        return true;
    }
    
}