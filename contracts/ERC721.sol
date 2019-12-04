pragma solidity ^0.5.12;

import "./IERC721.sol";
import "./SafeMath.sol";

contract ERC721 is IERC721 {



    mapping (address => uint256) private _balanceOf;
    mapping (uint256 => address ) private _tokenOwner;
    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    



    modifier onlyBy(address _address)  {
        require(msg.sender == _address, "sender is not the correct address");
        _;
    }

    modifier isNonZeroAddress(address _address) { 
        require (_address != address(0), "address 0x0 is not valid"); 
        _; 
    }


    modifier tokenExists(uint256 _token) {
        require(_tokenOwner[_token] != address(0));
        _;
    }

    modifier isApprovedForTransfer(address _spender, uint256 _tokenId) {
        require(ownerOf(_tokenId) == _spender || getApproved(_tokenId) == _spender || isApprovedForAll(_tokenOwner[_tokenId], _spender), "_spender is not approved for transfer");
        _;
    }


    


    function balanceOf(address _address) public isNonZeroAddress(_address) view returns (uint256) {
        return _balanceOf[_address];
    }


    function ownerOf(uint256 _tokenId) public isNonZeroAddress(_tokenOwner[_tokenId]) view returns (address) {
        return _tokenOwner[_tokenId];

    }


    function approve(address _approved, uint256 _tokenId) external payable {
        require(_approved != msg.sender, "ERC721 : Owner is already approved");
        require(_tokenOwner[_tokenId] == msg.sender || isApprovedForAll(_tokenOwner[_tokenId], msg.sender));
        _tokenApprovals[_tokenId] = _approved;

        emit Approval(_tokenOwner[_tokenId], _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != msg.sender, "ERC721: Owner is already approved");
        _operatorApprovals[msg.sender][_operator] = _approved;

        emit ApprovalForAll(msg.sender, _operator, _approved);

    }

    function getApproved(uint256 _tokenId) public tokenExists(_tokenId) view returns (address) {
        return _tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }



    function transferFrom(address _from, address _to, uint256 _tokenId) external payable isNonZeroAddress(_to) tokenExists(_tokenId) 
    isApprovedForTransfer(_from, _tokenId) {
        require(_tokenOwner[_tokenId]==_from, "ERC721: transfer of token that is not owned");
        _balanceOf[_from] -= 1;
        _balanceOf[_to] += 1;
        _tokenOwner[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }



    function _transferFromContract(address _to, uint256 _tokenId) internal isNonZeroAddress(_to) tokenExists(_tokenId) {
        _balanceOf[address(this)] -= 1;
        _balanceOf[_to] += 1;
        _tokenOwner[_tokenId] = _to;

        emit Transfer(address(this), _to, _tokenId);
    }








    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _balanceOf[to]+=1;

        emit Transfer(address(0), to, tokenId);
    }



    function _exists(uint256 tokenId) internal view returns (bool) {
        address _owner = _tokenOwner[tokenId];
        return _owner != address(0);
    }



    function _burn(address _owner, uint256 tokenId) internal {
        require(_tokenOwner[tokenId] == _owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _balanceOf[_owner]-=1;
        _tokenOwner[tokenId] = address(0);

        emit Transfer(_owner, address(0), tokenId);
    }



    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0); }
        }
    

	
}