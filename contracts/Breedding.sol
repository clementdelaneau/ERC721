pragma solidity ^0.5.12;

import "./Auction.sol";

contract Breedding is AuctionSystem{


		function proposeToBreed(uint256 _dogId) public onlyBy(ownerOf(_dogId)) {
		require(availableToBreed[_dogId] == false, "dog is already available to breed");
		availableToBreed[_dogId] = true;
	}


		function breedAnimal(uint256 _dogId1, uint256 _dogId2) public {
		require(dogsById[_dogId1].isMale == true && dogsById[_dogId2].isMale == false || dogsById[_dogId1].isMale == false && dogsById[_dogId2].isMale == true, "not possible to breed same sex animals");
		require(_hasDog(msg.sender, _dogId1) || _hasDog(msg.sender, _dogId2), "message sender is not one of the token owner");
		require(availableToBreed[_dogId1] && availableToBreed[_dogId2], "dogs have to be available to breed");
		

		Race _race = _determineRaceAfterBreed(_dogId1, _dogId2);
		uint8 _category = (dogsById[_dogId1].category + dogsById[_dogId2].category)/2;

		if(_hasDog(msg.sender, _dogId1) && _hasDog(msg.sender, _dogId2))
		{
			declareAnimal(msg.sender, _race, true, 0, _category);


		}

		else 
		{ 
			_declareAnimalToContract(_race, true, 0, _category);

		}

	}



	function _determineRaceAfterBreed(uint256 _id1, uint256 _id2) internal view returns (Race race){
		Dog memory _dog1 = dogsById[_id1];
		Dog memory _dog2 = dogsById[_id2];

		if((_dog1.race == Race.Labrador && _dog2.race == Race.Pitbull) || (_dog1.race == Race.Pitbull && _dog2.race == Race.Labrador))
		{
			race = Race.Bullador;
		}
		else if((_dog1.race == Race.Pitbull && _dog2.race == Race.Husky) || (_dog1.race == Race.Husky && _dog2.race == Race.Pitbull))
		{
			race = Race.Pitsky;
		}
		else if((_dog1.race == Race.Terrier && _dog2.race == Race.Bouldog) || (_dog1.race == Race.Bouldog && _dog2.race == Race.Terrier))
		{
			race = Race.Pitbull;
		}
		else if((_dog1.race == Race.Labrador && _dog2.race == Race.Husky) || (_dog1.race == Race.Husky && _dog2.race == Race.Labrador))
		{
			race = Race.Labrador_Husky;
		}
		else 
		{
			race = Race.Unknown;
		} 
		return race;

	} 


}