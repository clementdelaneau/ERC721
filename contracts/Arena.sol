pragma solidity ^0.5.12;

import "./Breeding.sol";

contract Arena is Breeding {



	mapping(uint256 => uint256) public fightProposition;
	mapping(uint256 => Fight) public fightsById; 

	 uint256 private _nonce;



	struct Fight {
		uint256 dog1;
		uint256 dog2;
		uint256 bid;
		bool accepted;
		address winner;
	}




	function proposeToFight(uint256 _myDog, uint256 _opponent) public payable {
		require(ownerOf(_myDog) == msg.sender, "_myDog have to be owned by sender");
		require(ownerOf(_opponent) != msg.sender, "_opponent can't be from sender");
		require(dogsInAuction[_myDog] == false && dogsInAuction[_opponent] == false, "dogs must not be in auction");
		require(msg.value > 0, "value must be strictly positive");
		fightProposition[_myDog] = _opponent;
		uint256 _bid = uint256(msg.value);
		Fight memory fight = Fight(_myDog, _opponent, _bid, false, address(0));
		fightsById[_myDog] = fight;


	}


	function agreeToFight(uint256 _myDog, uint256 _opponent) public payable{
		require(ownerOf(_myDog) == msg.sender);
		require(fightProposition[_opponent] == _myDog);
		require(fightsById[_opponent].bid ==uint256(msg.value));
		require(fightsById[_opponent].accepted == false);
		fightProposition[_myDog] = _opponent;
		fightsById[_opponent].accepted = true;

		uint8 rand = _random();

		if(rand == 0) 
		{
			fightsById[_opponent].winner = ownerOf(_myDog);
			ownerOf(_myDog).transfer(2*fightsById[_opponent].bid);

		}
		else 
		{
			fightsById[_opponent].winner = ownerOf(_opponent);
			ownerOf(_opponent).transfer(2*fightsById[_opponent].bid);
		}
	}





	function _random() private returns (uint8 random) {
       random = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, _nonce, msg.sender)))%2);
       _nonce++;
       return random;

   }
   
}