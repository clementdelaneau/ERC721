pragma solidity ^0.5.12;

import "./Arena.sol";

contract DogCore is Arena {
	
	    address public newContractAddress;


    function setNewAddress(address _new) external onlyBy(owner) {

        newContractAddress = _new;
    }


}