// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;



import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";

contract addLiquidity {
      address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

      function al(address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to) public {
           
          IERC20(tokenA).transferFrom(msg.sender,address(this),amountADesired);
          IERC20(tokenB).transferFrom(msg.sender,address(this),amountBDesired);

          IERC20(tokenA).approve(UNISWAP_V2_ROUTER, amountADesired);
          IERC20(tokenB).approve(UNISWAP_V2_ROUTER, amountBDesired);

          IUniswapV2Router01(UNISWAP_V2_ROUTER).addLiquidity(tokenA,tokenB,amountADesired,amountBDesired,amountAMin,amountBMin,to,block.timestamp);
        }

      function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) external {
          
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

        address[] memory path;
        path[0] = _tokenIn;
        path[1] = _tokenOut;

        IUniswapV2Router01(UNISWAP_V2_ROUTER).swapExactTokensForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
    }  
}   

