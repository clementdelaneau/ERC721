pragma solidity ^0.6.1;

import "./Auction.sol";

contract Breeding is AuctionSystem{



	function proposeToBreed(uint256 _dogId) external onlyBy(ownerOf(_dogId)) {
		require(availableToBreed[_dogId] == false, "dog is already available to breed");
		availableToBreed[_dogId] = true;
	}


	function breedAnimal(uint256 _dogId1, uint256 _dogId2) external {
		require(dogsById[_dogId1].isMale == true && dogsById[_dogId2].isMale == false || dogsById[_dogId1].isMale == false && dogsById[_dogId2].isMale == true, "not possible to breed same sex animals");
		require(ownerOf(_dogId1) == msg.sender || ownerOf(_dogId2) == msg.sender, "message sender is not one of the token owner");
		require(availableToBreed[_dogId1] && availableToBreed[_dogId2], "dogs have to be available to breed");
		

		uint256 race = _determineRaceAfterBreed(uint256(dogsById[_dogId1].race),uint256(dogsById[_dogId2].race));
		Race _race = Race(race);

		uint8 _category = (dogsById[_dogId1].category + dogsById[_dogId2].category)/2;

		if(ownerOf(_dogId1) == msg.sender && ownerOf(_dogId2) == msg.sender)
		{
			declareAnimal(msg.sender, _race, true, 0, _category);

		}

		else 
		{ 
			_declareAnimalToContract(_race, true, 0, _category);

		}

	}



	function _determineRaceAfterBreed(uint256 _race1, uint256 _race2) private pure returns (uint256 race){

		if(_race1 == _race2) {
			race = _race1;
		}

		else if((_race1 == 0 && _race2 == 1) || (_race1 == 1 && _race2 == 0))
		{
			race = 5;
		}
		/*
		else if((_race1 == 1 && _race2 == 4) || (_race1 == 4 && _race2 == 1))
		{
			race = 6;
		}
		else if((_race1 == 2 && _race2 == 3) || (_race1 == 3 && _race2 == 2))
		{
			race = 1;
		}
		else if((_race1 == 0 && _race2 == 4) || (_race1 == 4 && _race2 == 0))
		{
			race = 7;
		}
		*/
		else 
		{
			race = 8;
		} 
		return race;

	} 


}