pragma solidity ^0.5.12;


import "./SafeMath.sol";
import "./ERC721.sol";

contract DogRegisterCoin is  ERC721 {

	 ERC721 internal _erc721;

	 address payable public owner;
     uint256 internal availableBalance;

    uint256 internal _nextId;


    mapping (address => bool) public _whitelist;
    mapping (uint256 => bool) public dogsInAuction; //dogid => bool


    mapping (uint => Dog) public dogsById;

    mapping (uint256 => bool) public availableToBreed;
    mapping (address => Dog[]) public breederDogs;




    


    Dog[] availableDogsToBreed;

    
    enum Race {Labrador, Pitbull, Terrier, Bouldog, Husky, Bullador, Pitsky, Labrador_Husky, Unknown}
    

	constructor() public {
		_erc721 = new ERC721();
		owner = msg.sender;

	}


	struct Dog {
		uint256 id;
		Race race;
		bool isMale;
		uint8 age;
		uint8 category;
	}







	modifier isRegistered(address _address) {
		require(_whitelist[_address] == true, "address is not registered");
		_;
	}

     
    //whitelist 
	function registerBreeder(address _breeder) public isNonZeroAddress(_breeder) onlyBy(owner) {
     require(_whitelist[_breeder] == false, "breeder already registered");
     _whitelist[_breeder] = true;
	}


	function declareAnimal(address payable _breeder, Race _race, bool _isMale, uint8 _age, uint8 _category) public isNonZeroAddress(_breeder) returns (bool) {
		require(_breeder == msg.sender, "breeder address is not correct");
		_nextId++;
       Dog memory dog = Dog(_nextId, _race, _isMale, _age, _category);
       breederDogs[_breeder].push(dog);
       dogsById[_nextId] = dog;

       _mint(_breeder, _nextId);
       return true;
	}


	function deadAnimal(uint _tokenId) public onlyBy(ownerOf(_tokenId)){
		address tokenOwner = ownerOf(_tokenId);
		_burn(msg.sender, _tokenId);
		delete dogsById[_tokenId];
		_removeFromArray(tokenOwner, _tokenId);
	}



	
function TransferAnimal(address payable _to, uint256 _id) public onlyBy(ownerOf(_id)) {
	require(dogsInAuction[_id] == false, "can't transfer animal which is in auction");
	_erc721.transferFrom(msg.sender, _to, _id);
	_removeFromArray(msg.sender,_id);
	breederDogs[_to].push(dogsById[_id]);

}

/*
	function TransferAnimalFrom(address _from, address payable _to, uint256 _id) public isRegistered(_to) {
		require(dogsInAuction[_id] == false, "can't transfer animal which is in auction");
		_removeFromArray(_from, _id);
		_erc721.transferFrom(_from, _to , _id);

	}*/


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

function _removeFromArray(address tokenOwner, uint256 _id) internal {
    uint i = 0;
    uint j =0;
    uint length = breederDogs[tokenOwner].length;
	while(breederDogs[tokenOwner][i].id != _id)
	{
		i++;
	}
	if(i == length-1) {
	delete breederDogs[tokenOwner][i];

	}
	else {
	for(j=i; j<length-1; j++) {
		breederDogs[tokenOwner][j] = breederDogs[tokenOwner][j+1];
	}
	delete breederDogs[tokenOwner][length-1];

	}
	length--;

}





}