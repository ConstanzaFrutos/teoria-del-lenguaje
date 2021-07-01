pragma solidity ^0.8.0;

interface ERC721 {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  function balanceOf(address _owner) external view returns (uint256);
  function ownerOf(uint256 _tokenId) external view returns (address);
  function transfer(address _to, uint256 _tokenId) external;
  function approve(address _to, uint256 _tokenId) external;
  function takeOwnership(uint256 _tokenId) external;
}

contract ERC721Metadata {
  // Nombre del token
  string private _name;

  // Simbolo del token
  string private _symbol;

  /**
    * @dev Inicializa el contrato con un nombre y un simbolo
    */
  constructor(string memory name_, string memory symbol_) {
      _name = name_;
      _symbol = symbol_;
  }

  function name() public view returns (string memory) {
      return _name;
  }
  
  function symbol() public view returns (string memory) {
      return _symbol;
  }
}
