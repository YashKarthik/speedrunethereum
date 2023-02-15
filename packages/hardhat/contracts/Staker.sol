// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping (address => uint256) public balances;
  bool public openForWithdraw;

  uint public constant THRESHOLD = 1 ether;
  uint256 public DEADLINE = block.timestamp + 1 minutes;
  
  event Stake(address, uint256);

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted {
    bool completed = exampleExternalContract.completed();
    require(!completed, "Executed");
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake() external payable {
      balances[msg.sender] += msg.value;
      emit Stake(msg.sender, msg.value);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() notCompleted public {
      require(block.timestamp >= DEADLINE, "Staking deadline not crossed yet.");

      if (address(this).balance >= THRESHOLD) {
        exampleExternalContract.complete{value: address(this).balance}();
      } else {
        openForWithdraw = true;
      }
  }


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() notCompleted public {
      require(openForWithdraw, "Contract not openForWithdraw");
      uint balance = balances[msg.sender];
      delete balances[msg.sender];
      (bool success,) = payable(msg.sender).call{value: balance}("");
      require(success, "Withdraw failed");
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() view public returns (uint) {
      if (block.timestamp >= DEADLINE) return 0;
      return DEADLINE - block.timestamp;
  }


  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
      this.stake{value: msg.value}();
  }
}
