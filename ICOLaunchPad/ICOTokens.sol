pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol";



contract ICOtokens is ERC20 {
    address public owner;
    constructor() ERC20("ICO","IC"){
        // _mint(msg.sender,80000 * 10 ** decimals());
        owner = msg.sender;
    }
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    function mint(address _owner,uint amount) public {
        _mint(_owner,amount * 10 ** decimals());
    }
    function burn(address _owner,uint amount) public {
        _burn(_owner,amount * 10 ** decimals());
    }
}
