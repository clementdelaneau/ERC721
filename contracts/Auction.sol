pragma solidity ^0.5.12;

import "./DogRegisterCoin.sol";

contract AuctionSystem is DogRegisterCoin {
using SafeMath for uint256;

    mapping (uint256 => Auction) public auction; //mapping between dogid and auction


    mapping (address => uint256) public bidderToBid;


		struct Auction {
		address payable chairperson;
		address payable[] bidders;
		uint256 startingPrice;
		uint256 startTime;
		uint256 highestBid;
		address winner;
	}


		function _declareAnimalToContract( Race _race, bool _isMale, uint8 _age, uint8 _category) internal returns (bool) {
		address payable breeder = address(uint160(address(this)));
		_nextId++;
       Dog memory dog = Dog(_nextId, _race, _isMale, _age, _category);
       breederDogs[breeder].push(dog);
       dogsById[_nextId] = dog;

       	_auctionByContract(_nextId);
       
       _mint(breeder, _nextId);
       return true;
	}
	

	function getHighestBid(uint256 _id) public view returns (uint256){
		return auction[_id].highestBid;
	}


	function createAuction(uint256 _id, uint256 _startingPrice) public onlyBy(ownerOf(_id)){
		require(!dogsInAuction[_id], "dog is already in auction");
		Auction memory auc;
		auc.chairperson = msg.sender;
		auc.startTime = now;
		auc.startingPrice = _startingPrice;
		auc.highestBid = _startingPrice;
		auc.winner = address(0);

		dogsInAuction[_id] = true;
		auction[_id] = auc;

	}
	
	


	function bidAuction(uint256 _id) public payable {
		require(_tokenOwner[_id] != msg.sender, "token owner can't be message sender");
		require(dogsInAuction[_id] == true, "dog is not in auction");
		require(msg.value > auction[_id].highestBid, "msg.value must be superior to the highest bid");
		require(auction[_id].startTime + 2 days >= now, "auction is finished");
		require(bidderToBid[msg.sender] == 0, "bidder cannot bid on several auctions in the same time");
		bidderToBid[msg.sender] = msg.value;
		auction[_id].bidders.push(msg.sender);
		auction[_id].highestBid = msg.value;

	}

	function updateBid(uint256 _id) public payable {
		require((bidderToBid[msg.sender] + msg.value) > auction[_id].highestBid, "updated bid must be superior to current highest bid");
		require(auction[_id].startTime + 2 days >= now, "auction is finished");
		bidderToBid[msg.sender] = bidderToBid[msg.sender].add(msg.value);
		auction[_id].highestBid = bidderToBid[msg.sender];
	}


	function claimAuction(uint256 _id) public payable{
		require(dogsInAuction[_id] == true, "dog must be in auction");
		require(now > auction[_id].startTime + 2 days, "auction is not finished yet");
		require(bidderToBid[msg.sender] == auction[_id].highestBid, "sender is not the winner");
		auction[_id].winner = msg.sender;

        _repayAuctionLosers(_id);
		_erc721.transferFrom(ownerOf(_id), msg.sender, _id);

		if(auction[_id].chairperson != address(uint160(address(this)))) {
			auction[_id].chairperson.transfer(auction[_id].highestBid);
		}

		else {
			availableBalance.add(auction[_id].highestBid);
		}


	}

		function _auctionByContract(uint256 _id) internal  {
		require(!dogsInAuction[_id], "dog is already in auction");

		Auction memory auc;
		auc.chairperson = address(uint160(address(this)));
		auc.startTime = now;
		auc.startingPrice = 1;
		auc.highestBid = 0;
		auc.winner = address(0);

		dogsInAuction[_id] = true;
		auction[_id] = auc;
	}






	function _repayAuctionLosers(uint256 _id) private{
	for(uint i =0; i< auction[_id].bidders.length; i++) {
		if(auction[_id].bidders[i] != auction[_id].winner) {
			auction[_id].bidders[i].transfer(bidderToBid[auction[_id].bidders[i]]);
			bidderToBid[auction[_id].bidders[i]] = 0;
		}
	}
	bidderToBid[auction[_id].winner] = 0;

}

}