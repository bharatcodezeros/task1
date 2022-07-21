// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MyToken is ERC20{
    constructor() ERC20("CODEZEROS","CDC") {
        
    }

    function mint(uint amount) public returns(bool){
        _mint(msg.sender,amount);
        return true;
    }

    function burn(uint amount) public returns(bool){
        _burn(msg.sender,amount);
        return true;
    }
}

