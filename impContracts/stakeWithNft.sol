// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "./nft.sol";

interface imyNftInterface{
    function mintNft(address recipient) external;
}

contract stake {
    mapping (address => uint) stakes;

    uint initialTime;
    uint timePeriod;

    address private nftContractaddress =0x3328358128832A260C76A4141e19E2A943CD4B6D;

    function stakeTokens(address token, uint amount, uint _timePeriod) public {
        IERC20(token).transferFrom(msg.sender,address(this),amount);
        initialTime = block.timestamp;
        timePeriod = initialTime + _timePeriod;
        stakes[msg.sender] = stakes[msg.sender] + amount;
    }
    function unstakeTokens(address token, uint amount) public {
        require(block.timestamp >= timePeriod,"Tokens are only availabe after the timeperiod elapsed");
        IERC20(token).transfer(msg.sender,amount);
        imyNftInterface(nftContractaddress).mintNft(msg.sender);
        stakes[msg.sender] = stakes[msg.sender] - amount;

    }
}

