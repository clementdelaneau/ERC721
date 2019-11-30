pragma solidity ^0.5.12;

import "./Arena.sol";

contract DogCore is Arena {
	


function() external payable {
	_availableBalance += msg.value;

}


function getAvailableBalance() external view onlyBy(owner) returns (uint256) {
		return _availableBalance;
}


function withdrawAvailableBalance() external onlyBy(owner) {
	require(_availableBalance >= 0.1 ether,"availableBalance too small");

	owner.transfer(_availableBalance);
	_availableBalance = 0;

}



}