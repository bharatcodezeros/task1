// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDC is ERC20{
    uint public amount;
    uint public rate = 0.1 ether;
    uint public tokens = 100 * 10**9;
    uint public noTokens ;
    constructor() ERC20("USDC","USDC_token"){
        _mint(msg.sender,5000 * 10 **9);

    }
    function pay() payable public returns(uint){
        amount = msg.value;
        noTokens = (amount * tokens);
        noTokens = noTokens / 100000000000000000;
        return noTokens;
    }
    function payTokens(address payer) public{
        transfer(payer,noTokens);
    }

}
