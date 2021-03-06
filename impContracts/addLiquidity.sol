// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "https://github.com/t4sk/defi-by-example/blob/main/contracts/interfaces/Uniswap.sol";


contract AddLiquidity {
  address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
  address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  event Log(string message, uint val);

  function addLiquidity(
    address _tokenA,
    address _tokenB,
    uint _amountA,
    uint _amountB
  ) external {
    IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);
    IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountB);

    IERC20(_tokenA).approve(ROUTER, _amountA);
    IERC20(_tokenB).approve(ROUTER, _amountB);

    (uint amountA, uint amountB, uint liquidity) =
      IUniswapV2Router(ROUTER).addLiquidity(
        _tokenA,
        _tokenB,
        _amountA,
        _amountB,
        1,
        1,
        address(this),
        block.timestamp
      );

    emit Log("amountA", amountA);
    emit Log("amountB", amountB);
    emit Log("liquidity", liquidity);
  }
  function _swap(address _from,address _to,uint _amount)external{
    IERC20(_from).transferFrom(msg.sender, address(this), _amount); 
    IERC20(_from).approve(ROUTER, _amount);
    address[] memory path = new address[](2);
    path = new address[](2);
    path[0] = _from;
    path[1] = _to;

    IUniswapV2Router(ROUTER).swapExactTokensForTokens(_amount,1,path, address(this),block.timestamp);
  }
}

