pragma solidity ^0.6.2;

import "./Breeding.sol";

contract Arena is Breeding {


	event FightProcessed(uint256 dog1, uint256 dog2, address winner);

	mapping(uint256 => Fight) public fightsById; 
	mapping (uint256 => uint256) private dogToLastFight;
	
	

	uint256 private _nonce;
	uint256 private _fightId;


	struct Fight {
		uint256 id;
		uint256 dog1;
		uint256 dog2;
		uint256 startime;
		uint256 victoriousDog;
		uint256 bid;
		bool accepted;
		address winner;
	}




	function proposeToFight(uint256 _myDog, uint256 _opponent) external onlyBy(ownerOf(_myDog)) payable  {
		require(!_isInAuction(_myDog) && !_isInAuction(_opponent));
		require(ownerOf(_opponent) != msg.sender, "_opponent can't be from sender");
		require(msg.value > 0, "value must be strictly positive");
		require(now >= fightsById[dogToLastFight[_myDog]].startime + 1 days);
		require(now >= fightsById[dogToLastFight[_opponent]].startime + 1 days);
		_fightId++;
		uint256 _bid = uint256(msg.value);
		Fight memory fight = Fight(_fightId, _myDog, _opponent, now, 0, _bid, false, address(0));
		fightsById[_fightId] = fight;
	}


	function agreeToFight(uint256 _id) external onlyBy(ownerOf(fightsById[_id].dog2)) payable {
		require(fightsById[_id].bid == uint256(msg.value), "sent value should be the same as the bid");
		require(fightsById[_id].accepted == false, "opponent's dog should not be engaged in a fight");
		require(now >= fightsById[dogToLastFight[fightsById[_id].dog1]].startime + 1 days);
		require(now >= fightsById[dogToLastFight[fightsById[_id].dog2]].startime + 1 days);
		dogToLastFight[fightsById[_id].dog1] = _id;
		dogToLastFight[fightsById[_id].dog2] = _id;		
		fightsById[_id].accepted = true;

		uint8 rand = _random();

		if(rand == 0) 
		{
			fightsById[_id].winner = ownerOf(fightsById[_id].dog1);
			fightsById[_id].victoriousDog = fightsById[_id].dog1;

		}
		else 
		{
			fightsById[_id].winner = ownerOf(fightsById[_id].dog2);
			fightsById[_id].victoriousDog = fightsById[_id].dog2;
		}

		emit FightProcessed(fightsById[_id].dog1, fightsById[_id].dog2, fightsById[_id].winner);

		address payable winner = payable(fightsById[_id].winner);
		uint256 gain = fightsById[_id].bid;
		fightsById[_id].bid = 0;
		(bool success, ) = winner.call.value(2*gain)("");
		require(success, "transfer failed");
		//winner.transfer(2*gain);


	}



	function _random() private returns (uint8 random) {
		random = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, _nonce, msg.sender)))%2);
		_nonce++;
		return random;

	}

	
}