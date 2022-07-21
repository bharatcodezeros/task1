// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
// import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/VRFConsumerBase.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract gambling is VRFConsumerBase{

    struct ticketInfo{
        address purchaser;
        bool sold;
    }

    struct sessionsDetails{
        uint startDate;
        uint endDate;
        address token;
        uint PurchaseAmount;  
        uint raisedAmount;
        address winner;
    }

    address public manager;
    mapping (address => uint) public stakes;
    mapping(uint => mapping(uint => ticketInfo)) public stakersData;
    mapping(uint => sessionsDetails) public sessions;
    uint sessionCount;

    bytes32 internal keyHash; 
    uint internal fee; 
    uint public randomResult;
    address vrfcoordinator = 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B;
    address linkToken = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    uint ticket;

    using SafeMath for uint;

    constructor()VRFConsumerBase(
            vrfcoordinator, // vrfcoordinator is address of smart contract that verifies the randomness of number returned smart contract.
            linkToken
            ) {
            keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
            fee = 0.1 * 10 ** 18;
            manager = msg.sender;
        }


    modifier onlyManger{
        require(manager == msg.sender,"Only authorize manager access it");
        _;
    }
    modifier conditionstoPurchase(uint sId,address _token,uint amount,uint _ticketId){
        require(sessions[sId].token == _token,"Require particular token");
        require(sessions[sId].PurchaseAmount == amount,"Require particular amount");
        require(stakersData[sId][_ticketId].sold==false,"already sold");
        require(block.timestamp > sessions[sId].startDate,"not started yet");
        require(block.timestamp < sessions[sId].endDate,"sesssion ended");
        _;
    }


    function session(uint _sDate,uint _eDate,address _stoken,uint _PurchaseAmount) external onlyManger{
        sessionCount++;
        sessionsDetails storage s = sessions[sessionCount];
        sessions[sessionCount].startDate = _sDate;
        sessions[sessionCount].endDate = _eDate;
        s.token = _stoken;
        s.PurchaseAmount = _PurchaseAmount;
    }

    function stakeTokens(uint sessionId,address _token, uint amount,uint _ticketId) external conditionstoPurchase(sessionId,_token,
        amount,_ticketId){
        IERC20(_token).transferFrom(msg.sender,address(this),amount);
        stakersData[sessionId][_ticketId].purchaser=msg.sender;
        stakersData[sessionId][_ticketId].sold = true;
        sessions[sessionId].raisedAmount += amount;

        
    }

    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in contract");
        return requestRandomness(keyHash, fee);
    }

     function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
         randomResult = randomness.mod(100).add(1);
    }

    function pickWinner(uint sId) public  onlyManger {
        // require(block.timestamp > sessions[sId].endDate);
        getRandomNumber();
        sessions[sId].winner = stakersData[sId][randomResult].purchaser;
        payWinner(sId);
    }

    function payWinner(uint sId) public {
        sessionsDetails storage s = sessions[sId];
        if (s.winner == address(0)){
            IERC20(s.token).transfer(manager,s.raisedAmount);
        }
        else{
            IERC20(s.token).transfer(sessions[sId].winner,s.raisedAmount);
        }
    }

}

