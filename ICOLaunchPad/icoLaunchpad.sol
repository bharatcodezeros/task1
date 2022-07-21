pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IWETH.sol";
import "https://github.com/Uniswap/solidity-lib/blob/master/contracts/libraries/TransferHelper.sol";
// contract ICOtokens is ERC20 {
//     address public owner;
//     constructor() ERC20("ICO","IC"){
//         // _mint(msg.sender,80000 * 10 ** decimals());
//         owner = msg.sender;
//     }
//     modifier onlyOwner{
//         require(msg.sender == owner);
//         _;
//     }
//     function mint(address _owner,uint amount) public {
//         _mint(_owner,amount * 10 ** decimals());
//     }
//     function burn(address _owner,uint amount) public {
//         _burn(_owner,amount * 10 ** decimals());
//     }
// }
interface imyNftInterface{
    function mintNft(address recipient) external;
}
interface IERC202{
    function mint(address _owner,uint amount) external;
    function burn(address _owner,uint amount) external;
}
contract ICOLaunchpad {
    // address private constant icoToken = 0x14cD3C7160A1Bc4313F5591DB1786E00c1A904af;
    address private nftContractaddress = 0x6339Aa52b93403c421D20a2c70A7b7E7cc104B20;
    address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    event ALE(uint,uint,uint);
    event RLE(uint,uint);
    using SafeMath for uint;
    address private manager;
    struct Project{
        string name;
        address payable owner;
        string description;
        uint startDate;
        uint endDate;
        uint targetAmount;
        uint rate;
        uint icoTokens;
        uint amountGenerated;
        address projectAdd;
    }
    struct Cdata{
        uint amount;
        uint tokens;
        uint date ;
        bool refund;
        bool reward;
    }
    // uint timePeriod;
    uint percent = 25 ;
    event T (address ,uint );
    mapping(string => Project) public projects;
    mapping(string => mapping (address=>Cdata)) public contributors;
    constructor(){
        manager = msg.sender;
    }
    modifier onlyManger{
        require(manager == msg.sender,"Only authorize manager access it");
        _;
    }
    modifier lock1(string memory _name){
        Project storage p = projects[_name];
        uint timePeriod = p.endDate + 60;
        require(block.timestamp > timePeriod);
        _;
    }
    modifier lock2(string memory pname,address add){
        Cdata storage cd = contributors[pname][add];
        uint timePeriod = cd.date + 60;
        require(block.timestamp > timePeriod);
        _;
    }
    // uint sD, uint eD
    function listProject(string memory _name,string memory _desc,uint _targetAmount,uint _rate,
        uint _icoTokens,address _add) external {
        Project  storage newP = projects[_name];
        newP.name = _name;
        newP.owner = payable(msg.sender);
        newP.description = _desc;
        newP.startDate = 1654021800;
        newP.endDate = 1656613799;
        newP.targetAmount = _targetAmount;
        newP.rate = _rate;
        newP.icoTokens = _icoTokens;
        newP.projectAdd = _add;
    }
    function fundProject(string memory _name) public payable{
        Project  storage p = projects[_name];
        require(block.timestamp > p.startDate,"project no yet start");
        require(block.timestamp < p.endDate,"project ends");
        uint amount =msg.value;
        p.amountGenerated += msg.value;
        contributors[_name][msg.sender].amount = msg.value;
        uint noTokens = amount.mul(p.icoTokens);
        noTokens = noTokens.div(p.rate);
        contributors[_name][msg.sender].tokens= noTokens;
        contributors[_name][msg.sender].date = block.timestamp;
        IERC202(p.projectAdd).mint(msg.sender,noTokens);
        emit T(msg.sender,noTokens);
    }
    // lock1
    function fundTransfer(string memory _name) public lock1(_name){
        Project storage p = projects[_name];
        require(p.amountGenerated >= p.targetAmount);
        require(p.owner == msg.sender);
        p.owner.transfer(p.amountGenerated);
        p.amountGenerated = 0;
    
    }
    function refund(string memory _name,address add) external lock2(_name,add){
        Project  storage p = projects[_name];
        Cdata storage c = contributors[_name][msg.sender];
        // require(block.timestamp >= p.startDate);
        // require(block.timestamp < p.endDate);
        require(msg.sender == add);
        require(contributors[_name][msg.sender].reward == false);
        require(contributors[_name][msg.sender].amount > 0);
        address payable contributor = payable(msg.sender);
        percent = (c.amount.div(100)).mul(percent);
        c.amount = c.amount.sub(percent);
        contributor.transfer(c.amount);
        contributors[_name][msg.sender].amount=0;
        IERC202(p.projectAdd).burn(msg.sender,contributors[_name][msg.sender].tokens);
        contributors[_name][msg.sender].tokens=0;
        contributors[_name][msg.sender].refund = true;
    }
    // lock2(_name,add)
    function reaward(string memory _name,address add) external lock2(_name,add) {
        require(msg.sender == add);
        require(contributors[_name][msg.sender].amount > 0);
        require(contributors[_name][msg.sender].refund == false);
        contributors[_name][msg.sender].reward = true;
        imyNftInterface(nftContractaddress).mintNft(add);
    }
    function investETH(
        address token,
        uint amountTokenDesired
    ) external payable onlyManger{
    IERC20(token).transferFrom(msg.sender,address(this),amountTokenDesired);
    IERC20(token).approve(ROUTER, amountTokenDesired);
    (uint amountToken, uint amountETH, uint liquidity)=
    IUniswapV2Router02(ROUTER).addLiquidityETH{value: address(this).balance}(token,
    amountTokenDesired,
    1,
    1,
    address(this),
    block.timestamp);
    emit ALE(amountToken,amountETH,liquidity);
    }
    

    receive() external payable {
        // assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function getbackETH(address token)external payable onlyManger{
        address pair = IUniswapV2Factory(FACTORY).getPair(token, WETH);
        uint liquidity= IERC20(pair).balanceOf(address(this));
        IERC20(pair).approve(ROUTER, liquidity);
        (uint amountToken, uint amountETH) =
        IUniswapV2Router02(ROUTER).removeLiquidityETH(
          token,
          liquidity,
          1,
          1,
          address(this),
          block.timestamp
        );
        emit RLE(amountToken,amountETH);
  }

    function cbalance()external view returns(uint){
        return address(this).balance;
    }



}








