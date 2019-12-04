pragma solidity ^0.5.12;

import "./Breeding.sol";

contract Arena is Breeding {


    event FightProcessed(uint256 dog1, uint256 dog2, address winner);

	mapping(uint256 => uint256) private fightProposition;
	mapping(uint256 => Fight) public fightsById; 

	 uint256 private _nonce;



	struct Fight {
		uint256 dog1;
		uint256 dog2;
		uint256 victoriousDog;
		uint256 bid;
		bool accepted;
		address winner;
	}




	function proposeToFight(uint256 _myDog, uint256 _opponent) public onlyBy(ownerOf(_myDog)) isNotInAuction(_myDog) isNotInAuction(_opponent) payable  {
		require(fightProposition[_myDog] == 0, "dog owner not already engaged in fight");
		require(fightProposition[_opponent] == 0, "dog opponent not already engaged in a fight");
		require(ownerOf(_opponent) != msg.sender, "_opponent can't be from sender");
		require(msg.value > 0, "value must be strictly positive");
		fightProposition[_myDog] = _opponent;
		uint256 _bid = uint256(msg.value);
		Fight memory fight = Fight(_myDog, _opponent, 0, _bid, false, address(0));
		fightsById[_myDog] = fight;


	}


	function agreeToFight(uint256 _myDog, uint256 _opponent) public onlyBy(ownerOf(_myDog)) payable {
		require(fightProposition[_opponent] == _myDog);
		require(fightsById[_opponent].bid ==uint256(msg.value));
		require(fightsById[_opponent].accepted == false);
		fightProposition[_myDog] = _opponent;
		fightsById[_opponent].accepted = true;
		uint8 rand = _random();

		if(rand == 0) 
		{
			fightsById[_opponent].winner = ownerOf(_myDog);
			fightsById[_opponent].victoriousDog = _myDog;

		}
		else 
		{
			fightsById[_opponent].winner = ownerOf(_opponent);
			fightsById[_opponent].victoriousDog = _opponent;
		}
		fightProposition[fightProposition[fightsById[_opponent].victoriousDog]] =0;

		emit FightProcessed(_opponent, _myDog, fightsById[_opponent].winner);
	}



	function claimAfterFight(uint256 _id) public onlyBy(fightsById[_id].winner) payable {
		address payable winner = address(uint160(fightsById[_id].winner));
        uint256 gain = fightsById[_id].bid;
        fightsById[_id].bid = 0;
		winner.transfer(2*gain);
		fightProposition[fightsById[_id].victoriousDog] = 0;
		_reinitializeFight(_id);
	}





	function _random() private returns (uint8 random) {
       random = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, _nonce, msg.sender)))%2);
       _nonce++;
       return random;

   }

   function _reinitializeFight(uint256 _id) private {
   	fightsById[_id].dog1 = 0;
   	fightsById[_id].dog2 = 0;
   	fightsById[_id].victoriousDog = 0;
   	fightsById[_id].accepted = false;
   	fightsById[_id].winner = address(0);
   }
   
}