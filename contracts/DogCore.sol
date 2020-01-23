pragma solidity ^0.6.0;

import "./Arena.sol";

contract DogCore is Arena {
	
event DepositReceived(uint256 value);



receive() external payable { 
	require(msg.data.length == 0); 
	_availableBalance += msg.value; 
	emit DepositReceived(msg.value); 
}


function getAvailableBalance() external view onlyBy(owner) returns (uint256) {
		return _availableBalance;
}


function withdrawAvailableBalance() external onlyBy(owner) {
	require(_availableBalance >= 0.1 ether,"availableBalance too small");
    uint256 value = _availableBalance;
    _availableBalance = 0;
	(bool success, ) = owner.call.value(value)("");
	require(success, "transfer failed");
	
	

}



}