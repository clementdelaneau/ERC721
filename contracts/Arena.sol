pragma solidity ^0.5.0;

import "./DogRegisterCoin.sol";


contract Arena is DogRegisterCoin {



	mapping(uint256 => uint256) public fightProposition;
	mapping(uint256 => Fight) public fightsById; //fight id is sum of the two dogs ids

	 uint256 private _nonce;



	struct Fight {
		uint256 dog1;
		uint256 dog2;
		uint256 bid;
		bool accepted;
		address winner;
	}




	function proposeToFight(uint256 _id1, uint256 _id2) public payable{
		require(ownerOf(_id1) == msg.sender);
		require(dogsInAuction[_id1] == false);
		require(msg.value > 0);
		fightProposition[_id1] = _id2;
		uint256 _bid = uint256(msg.value);
		Fight memory fight = Fight(_id1, _id2, _bid, false, address(0));
		fightsById[_id1+_id2] = fight;


	}


	function agreeToFight(uint256 _id1, uint256 _id2) public payable{
		uint256 _bid = uint256(msg.value);
		require(ownerOf(_id1) == msg.sender);
		require(fightProposition[_id2] == _id1);
		require(fightsById[_id1 +_id2].bid ==  _bid);
		fightProposition[_id1] = _id2;
		fightsById[_id1+_id2].accepted = true;

		_fight(_id1, _id2);	

	}


	function _fight(uint256 _id1, uint256 _id2) public payable{
		require(fightProposition[_id1] == _id2 && fightProposition[_id2] == _id1);
		require(fightsById[_id1+_id2].accepted = true);

		_random();

		if(_random() == 0) 
		{
			fightsById[_id1+_id2].winner = ownerOf(_id1);
			ownerOf(_id1).transfer(fightsById[_id1 +_id2].bid);

		}
		else 
		{
			fightsById[_id1 + _id2].winner = ownerOf(_id2);
			ownerOf(_id2).transfer(fightsById[_id1 +_id2].bid);
		}

	}


	function _random() private returns (uint8 random) {
       random = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, _nonce, msg.sender)))%2);
       _nonce++;
       return random;

   }
   
}