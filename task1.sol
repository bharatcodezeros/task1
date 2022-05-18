// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
	uint decimal = 9;
	uint c = 1;
	// uint public  totalsupply;
    constructor() ERC20("CODEZEROS", "CODE") {
		_mint(msg.sender,5000 * 10**decimal);
	}

	function transfer(address to, uint amount) public virtual override returns(bool){
		if (c == 3 || c == 4){
            _transfer(msg.sender,to,amount);
            if (c == 4){
                c = 1;
                return true;
            }
            c++;
            return true;
        }
        else{
            amount  = amount - 3;
			_transfer(msg.sender,to,amount);
            c++;
            return true;
        }
    }
    function mint(uint amount) public returns(bool){
        _mint(msg.sender,amount);
        return true;
    }

}
