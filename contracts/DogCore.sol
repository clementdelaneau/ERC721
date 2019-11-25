pragma solidity ^0.5.12;

import "./Arena.sol";

contract DogCore is Arena {
	


function() external payable {

}


function getAvailableBalance() external view onlyBy(owner) returns (uint256) {
		return availableBalance;
}


function withdrawAvailableBalance() external onlyBy(owner) {
	require(availableBalance > 0.1 ether,"availableBalance too small");

	owner.transfer(availableBalance);

}



}