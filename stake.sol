// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITaskinterface {
    function transferFrom (address from, address to, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
     function transfer(address to, uint256 amount) external returns (bool);
}


contract task2 {
    mapping(address => uint) public stakes;
    uint public totalsupply;
    function stake(address token,uint amount)public {
        ITaskinterface(token).transferFrom(msg.sender,address(this),amount);
        stakes[msg.sender] = stakes[msg.sender]+amount;
        totalsupply = totalsupply + amount;
    }

    function withdraw(address token,uint amount)public{
        ITaskinterface(token).transfer(msg.sender,amount);
        stakes[msg.sender] = stakes[msg.sender]-amount;
        totalsupply = totalsupply - amount;
    }
} 
