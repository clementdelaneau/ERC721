pragma solidity ^0.5.12;

import "./DogRegisterCoin.sol";

contract AuctionSystem is DogRegisterCoin {
using SafeMath for uint256;

    event AuctionCreated(uint256 id, uint256 startingPrice, address chairperson);
    event AuctionClaimed(uint256 id, address winner);

    mapping (uint256 => Auction) public auction; //mapping between dogid and auction
    mapping (address => uint256) private _bidderToBid;


		struct Auction {
		address payable chairperson;
		address payable[] bidders;
		uint256 startingPrice;
		uint256 startTime;
		uint256 highestBid;
		address winner;
	}


		function _declareAnimalToContract(Race _race, bool _isMale, uint8 _age, uint8 _category) internal returns (bool) {
		address breeder = address(this);
		_nextId++;
       Dog memory dog = Dog(_nextId, _race, _isMale, _age, _category);
       dogsById[_nextId] = dog;

       	_auctionByContract(_nextId);
       
       _mint(breeder, _nextId);
       return true;
	}



	function getBid() public view onlyBy(msg.sender) returns(uint256) {
		return _bidderToBid[msg.sender];
	}
	



	function createAuction(uint256 _id, uint256 _startingPrice) public onlyBy(ownerOf(_id)) isNotInAuction(_id) {
		Auction memory auc;
		auc.chairperson = msg.sender;
		auc.startTime = now;
		auc.startingPrice = _startingPrice;
		auc.highestBid = _startingPrice;
		auc.winner = address(0);

		_transferAnimalFrom(msg.sender, address(this), _id);

		dogsInAuction[_id] = true;
		auction[_id] = auc;

		emit AuctionCreated(_id, _startingPrice, msg.sender);

	}
	
	


	function bidAuction(uint256 _id) public payable {
		require(ownerOf(_id) != msg.sender, "contract can't bid");
		require(auction[_id].chairperson != msg.sender, "chairperson can't bid on its own auction");
		require(dogsInAuction[_id] == true, "dog is not in auction");
		require(msg.value > auction[_id].highestBid, "msg.value must be superior to the highest bid");
		require(auction[_id].startTime + 2 days >= now, "auction is finished");
		require(_bidderToBid[msg.sender] == 0, "bidder cannot bid on several auctions in the same time");
		_bidderToBid[msg.sender] = msg.value;
		auction[_id].bidders.push(msg.sender);
		auction[_id].highestBid = msg.value;

	}

	function updateBid(uint256 _id) public payable {
		require((_bidderToBid[msg.sender] + msg.value) > auction[_id].highestBid, "updated bid must be superior to current highest bid");
		require(auction[_id].startTime + 2 days >= now, "auction is finished");
		_bidderToBid[msg.sender] = _bidderToBid[msg.sender].add(msg.value);
		auction[_id].highestBid = _bidderToBid[msg.sender];
	}


	function claimAuction(uint256 _id) public payable{
		require(dogsInAuction[_id] == true, "dog must be in auction");
		require(now > auction[_id].startTime + 2 days, "auction is not finished yet");
		require(_bidderToBid[msg.sender] == auction[_id].highestBid, "sender is not the winner");
		auction[_id].winner = msg.sender;
        uint256 finalPrice = auction[_id].highestBid;
        auction[_id].highestBid = 0;
        _repayAuctionLosers(_id);

		_transferAnimalFromContract(msg.sender, _id);

		if(auction[_id].chairperson != address(uint160(address(this)))) {
			auction[_id].chairperson.transfer(finalPrice - _fees(finalPrice));
			_availableBalance+=_fees(finalPrice);
		}

		else {
			_availableBalance+=finalPrice;
		}

		_reinitializeAuction(_id);

        emit AuctionClaimed(_id, msg.sender);
	}

	

		function _auctionByContract(uint256 _id) internal  {

		Auction memory auc;
		auc.chairperson = address(uint160(address(this)));
		auc.startTime = now;
		auc.startingPrice = 1;
		auc.highestBid = 0;
		auc.winner = address(0);

		dogsInAuction[_id] = true;
		auction[_id] = auc;

		emit AuctionCreated(_id, 1, auc.chairperson);

	}


	function _reinitializeAuction(uint256 _id) private {
		auction[_id].chairperson = address(0);
		delete auction[_id].bidders;
		auction[_id].startingPrice = 0;
		auction[_id].startTime = 0;
		auction[_id].winner = address(0);
	}






	function _repayAuctionLosers(uint256 _id) private{
	for(uint i =0; i< auction[_id].bidders.length; i++) {
		if(auction[_id].bidders[i] != auction[_id].winner) {
			auction[_id].bidders[i].transfer(_bidderToBid[auction[_id].bidders[i]]);
			_bidderToBid[auction[_id].bidders[i]] = 0;
		}
	}
	_bidderToBid[auction[_id].winner] = 0;

}

}