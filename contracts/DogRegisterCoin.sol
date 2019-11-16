pragma solidity ^0.5.0;


import "./SafeMath.sol";
import "./ERC721.sol";
//import "./BreedSystem.sol";
//import "./Auction.sol";
//import "./Arena.sol";


contract DogRegisterCoin is ERC721 {

    ERC721 private _erc721;
    address payable public owner;

    uint private _nextId;


    mapping (address => bool) public _whitelist;

    mapping (address => Dog[]) public breederDogs;

    mapping (uint => Dog) public dogsById;

    mapping (uint256 => bool) public availableToBreed;

    mapping (uint256 => bool) public dogsInAuction; //dogid => bool

    mapping (uint256 => Auction) public auction; //mapping between dogid and auction

    mapping (address => uint256) bid;


    Dog[] availableDogsToBreed;

    
    enum Race {Labrador, Pitbull, Terrier, Bouldog, Husky, Bullador, Pitsky, Labrador_Husky, Unknown}
    

	constructor() public {
		_erc721 = new ERC721();
		owner = msg.sender;

	}


	struct Dog {
		uint id;
		Race race;
		bool isMale;
		uint256 age;
		uint256 category;
	}

	struct Auction {
		address chairperson;
		uint256 startTime;
		uint256 startingPrice;
		uint256 highestBid;
		address winner;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}


	modifier isNotContractOwner() {
		require(msg.sender != address(this));
		_;
	}


	function contractBalance() public view returns (uint256) {
		return address(this).balance;
	}

     
    //whitelist 
	function registerBreeder(address _breeder) public isNonZeroAddress(_breeder) onlyOwner() {
     require(_whitelist[_breeder] == false, "breeder already registered");
     _whitelist[_breeder] = true;
	}


	function declareAnimal(address payable _breeder, Race _race, bool _isMale, uint256 _age, uint256 _category) public isNonZeroAddress(_breeder) returns (bool) {
		_nextId++;
       Dog memory dog = Dog(_nextId, _race, _isMale, _age, _category);
       breederDogs[_breeder].push(dog);
       dogsById[_nextId] = dog;
       if( _breeder == address(this))
       {
       	dogsInAuction[_nextId] = true;
       	_auctionByContract(_nextId);
       }
       _mint(_breeder, _nextId);
       return true;
	}

	function deadAnimal(uint _tokenId) public {
		require(msg.sender == ownerOf(_tokenId), "sender is not token owner");
		_burn(msg.sender, _tokenId);
		delete dogsById[_tokenId];
		_removeFromArray(_tokenId);
	}


	function breedAnimal(uint256 _dogId1, uint256 _dogId2) public {
		require(dogsById[_dogId1].isMale == true && dogsById[_dogId2].isMale == false || dogsById[_dogId1].isMale == false && dogsById[_dogId2].isMale == true, "not possible to breed same sex animals");
		require(_hasDog(msg.sender, _dogId1) || _hasDog(msg.sender, _dogId2), "message sender is not one of the token owner");
		require(availableToBreed[_dogId1] && availableToBreed[_dogId2], "dogs have to be available to breed");
		

		Race _race = _determineRaceAfterBreed(_dogId1, _dogId2);
		uint256 _category = (dogsById[_dogId1].category + dogsById[_dogId2].category)/2;

		if(_hasDog(msg.sender, _dogId1) && _hasDog(msg.sender, _dogId2))
		{
			declareAnimal(msg.sender, _race, true, 0, _category);


		}

		else 
		{ 
			declareAnimal(address(uint160(address(this))), _race, true, 0, _category);

		}

	}


	function proposeToBreed(uint256 _dogId) public {
		require(msg.sender == ownerOf(_dogId), "sender is not token owner");
		require(availableToBreed[_dogId] == false, "dog is already available to breed");
		availableToBreed[_dogId] = true;
	}



	function _hasDog(address _breeder, uint256 _dogId) internal view returns (bool success) {
		success = false;
		for(uint i = 0; i<breederDogs[_breeder].length; i++)
		{
			if(breederDogs[_breeder][i].id == _dogId) {
				success = true;
			}

		}
		return success;

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



	function getHighestBid(uint256 _id) public view returns (uint256){
		return auction[_id].highestBid;

	}


	function createAuction(uint256 _id, uint256 _startingPrice) public {
		require(_tokenOwner[_id] == msg.sender, "sender is not token owner");
		Auction memory auc = Auction(msg.sender, now,_startingPrice, 0, address(0));
		dogsInAuction[_id] = true;
		auction[_id] = auc;

	}
	
	
	function _auctionByContract(uint256 _id) internal {
	    require(_hasDog(address(this), _id), "sender is not contrat owner");
	   	Auction memory auc = Auction(address(this), now, 1, 0, address(0));
		dogsInAuction[_id] = true;
		auction[_id] = auc;
	}

	function bidAuction(uint256 _id) public payable {
		require(_tokenOwner[_id] != msg.sender, "token owner can't be message sender");
		require(dogsInAuction[_id] == true, "dog is not in auction");
		require(msg.value > auction[_id].highestBid, "msg.value must be superior to the highest bid");
		require(auction[_id].startTime + 2 days >= now, "auction is finished");
		bid[msg.sender] = msg.value;
		auction[_id].highestBid = msg.value;

	}

	function updateBid(uint256 _id) public payable {
		require((bid[msg.sender] + msg.value) > auction[_id].highestBid);
		bid[msg.sender] += msg.value;
	}


	function claimAuction(uint256 _id) public payable{
		require(dogsInAuction[_id] == true);
		require(now > auction[_id].startTime + 2 days);
		require(bid[msg.sender] == auction[_id].highestBid);

		_erc721.transferFrom(ownerOf(_id), msg.sender, _id);

		auction[_id].winner = msg.sender;
	}



	function TransferAnimal(address _from, address payable _to, uint256 _id) public {
		require(ownerOf(_id) == _from);
		require(dogsInAuction[_id] == false);
		require(_whitelist[_to] == true);
		_removeFromArray(_id);
		_erc721.transferFrom(_from, _to , _id);

	}



function _removeFromArray(uint256 _id) internal {
    uint i = 0;
	while (breederDogs[ownerOf(_id)][i].id != _id)
	{
		i++;
	}
	delete breederDogs[ownerOf(_id)][i];
}





}