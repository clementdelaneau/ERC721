pragma solidity ^0.6.2;

import "./DogRegisterCoin.sol";

contract AuctionSystem is DogRegisterCoin {
	using SafeMath for uint256;

	event AuctionCreated(uint256 id, uint256 startingPrice, address chairperson);
	event AuctionClaimed(uint256 id, address winner);

    mapping (uint256 => Auction) public auction; //mapping between dogid and auction
    mapping (address => uint256) private _bidderToBid;
    mapping (address => uint256[]) _bidderToBids;
    


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



    function getBid() external view onlyBy(msg.sender) returns(uint256) {
    	return _bidderToBid[msg.sender];
    }
    



    function createAuction(uint256 _id, uint256 _startingPrice) external onlyBy(ownerOf(_id)) {
    	require(!_isInAuction(_id));
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
    
    


    function bidAuction(uint256 _id) external payable {
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

    function updateBid(uint256 _id) external payable {
    	require((_bidderToBid[msg.sender] + msg.value) > auction[_id].highestBid, "updated bid must be superior to current highest bid");
    	require(auction[_id].startTime + 2 days >= now, "auction is finished");
    	_bidderToBid[msg.sender] = _bidderToBid[msg.sender].add(msg.value);
    	auction[_id].highestBid = _bidderToBid[msg.sender];
    }


    function claimAuction(uint256 _id) external payable{
    	require(now > auction[_id].startTime + 2 days, "auction is not finished yet");
    	require(_bidderToBid[msg.sender] == auction[_id].highestBid, "sender is not the winner");
    	auction[_id].winner = msg.sender;
    	uint256 finalPrice = auction[_id].highestBid;
    	auction[_id].highestBid = 0;
    	_repayAuctionLosers(_id);

    	_transferAnimalFromContract(msg.sender, _id);

    	if(auction[_id].chairperson != payable(address(this))) {
    		(bool success, ) = auction[_id].chairperson.call.value(finalPrice - _fees(finalPrice))("");
    		require(success, "transfer failed");
			//auction[_id].chairperson.transfer(finalPrice - _fees(finalPrice));
			_availableBalance+=_fees(finalPrice);
		}

		else {
			_availableBalance+=finalPrice;
		}

		auction[_id] = Auction(address(0),new address payable[](0),0,0,0,address(0));

		emit AuctionClaimed(_id, msg.sender);
	}

	

	function _auctionByContract(uint256 _id) internal  {

		Auction memory auc;
		auc.chairperson = payable((address(this)));
		auc.startTime = now;
		auc.startingPrice = 1;
		auc.highestBid = 0;
		auc.winner = address(0);

		dogsInAuction[_id] = true;
		auction[_id] = auc;

		emit AuctionCreated(_id, 1, auc.chairperson);

	}



	function _repayAuctionLosers(uint256 _id) private{
		for(uint i =0; i< auction[_id].bidders.length; i++) {
			if(auction[_id].bidders[i] != auction[_id].winner) {
				(bool success, ) = auction[_id].bidders[i].call.value(_bidderToBid[auction[_id].bidders[i]])("");
				require(success, "transfer failed");
			//auction[_id].bidders[i].transfer(_bidderToBid[auction[_id].bidders[i]]);
			_bidderToBid[auction[_id].bidders[i]] = 0;
		}
	}
	_bidderToBid[auction[_id].winner] = 0;

}

}