pragma solidity ^0.5.12;


import "./SafeMath.sol";
import "./ERC721.sol";

contract DogRegisterCoin is  ERC721 {


    event AnimalDeclared(address _breeder, uint256 _id);


	 address payable public owner;
     uint256 internal _availableBalance;
     uint256 internal _nextId;

    mapping (address => bool) private _whitelist;
    mapping (uint256 => bool) public dogsInAuction; 
    mapping (uint => Dog) public dogsById;
    mapping (uint256 => bool) public availableToBreed;
    mapping (address => Dog[]) private _breederDogs;


    enum Race {Labrador, Pitbull, Terrier, Bouldog, Husky, Bullador, Pitsky, Labrador_Husky, Unknown}
    


	constructor() public {
		owner = msg.sender;

	}


	struct Dog {
		uint256 id;
		Race race;
		bool isMale;
		uint8 age;
		uint8 category;
	}



	modifier isNotInAuction(uint256 _id) {
		require(dogsInAuction[_id] == false, "dog is in auction");
		_;
	}


	function isWhitelisted(address _address) public view onlyBy(owner) returns (bool) {
		return _whitelist[_address]; 
	}

     
    //whitelist 
	function registerBreeder(address _breeder) internal {
     require(_whitelist[_breeder] == false, "breeder already registered");
     _whitelist[_breeder] = true;
	}


	function declareAnimal(address _breeder, Race _race, bool _isMale, uint8 _age, uint8 _category) public isNonZeroAddress(_breeder) onlyBy(_breeder) returns (bool) {
		require(_whitelist[_breeder] == false, "breeder is already registered"); //breeder can only declare once a dog
		registerBreeder(_breeder);
		_nextId++;
       Dog memory dog = Dog(_nextId, _race, _isMale, _age, _category);
       _breederDogs[_breeder].push(dog);
       dogsById[_nextId] = dog;

       _mint(_breeder, _nextId);

       emit AnimalDeclared(_breeder, _nextId);
       return true;
	}


	function deadAnimal(uint _tokenId) public onlyBy(ownerOf(_tokenId)){
		address tokenOwner = ownerOf(_tokenId);
		_burn(msg.sender, _tokenId);
		delete dogsById[_tokenId];
		_removeFromArray(tokenOwner, _tokenId);
	}


function _transferAnimalFrom(address _from, address _to, uint256 _id) internal onlyBy(ownerOf(_id)) isNotInAuction(_id) {
	this.transferFrom(_from, _to, _id);
	_removeFromArray(_from,_id);
	_breederDogs[_to].push(dogsById[_id]);

}
	
function _transferAnimalFromContract(address _to, uint256 _id) internal {
	_transferFromContract(_to, _id);
	_removeFromArray(address(this),_id);
	_breederDogs[_to].push(dogsById[_id]);

}



function _removeFromArray(address tokenOwner, uint256 _id) private {
    uint i = 0;
    uint j =0;
    uint length = _breederDogs[tokenOwner].length;
	while(_breederDogs[tokenOwner][i].id != _id)
	{
		i++;
	}
	if(i == length-1) {
	delete _breederDogs[tokenOwner][i];

	}
	else {
	for(j=i; j<length-1; j++) {
		_breederDogs[tokenOwner][j] = _breederDogs[tokenOwner][j+1];
	}
	delete _breederDogs[tokenOwner][length-1];

	}
	length--;

}


function _fees(uint256 n) internal pure returns(uint256 fee) {

   fee = (3*n)/100;
   return fee;

}





}