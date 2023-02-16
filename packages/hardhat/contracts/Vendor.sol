pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
  
  uint public tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() payable public {
    uint _amount = tokensPerEth * (msg.value);
    yourToken.transfer(msg.sender, _amount);
    emit BuyTokens(msg.sender, msg.value, _amount);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public {
    require(msg.sender == owner(), "Only owner");
    (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
    require(success, "Withdraw failed.");
    
  }

  // ToDo: create a sellTokens(uint256 _amount) function:
  function sellTokens(uint256 _amount) public {
    uint _eth = _amount / tokensPerEth;
    yourToken.transferFrom(msg.sender, address(this), _amount);
    (bool success,) = payable(msg.sender).call{value: _eth}("");
    require(success, "sellTokens failed");
    emit SellTokens(msg.sender,_eth, _amount);
  }

}
