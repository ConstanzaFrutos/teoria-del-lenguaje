pragma solidity ^0.8.0;

import "./CartaHelper.sol";
import "./erc721.sol";

/**
 * @title CartaItem
 * @dev Funciones de administracion de cartas como 
 * compra de las mismas o transferencia de ownership
 */
contract CartaItem is CartaHelper, ERC721 {
    
    mapping (uint => address) cartaApprovals;

    function balanceOf(address _owner) public view override returns (uint256 _balance) {
        return personaCantidadCartas[_owner];
    }

    function ownerOf(uint256 _tokenId) public view override returns (address _owner) {
        return cartaAPersona[_tokenId];
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        personaCantidadCartas[_to]++;
        personaCantidadCartas[_from]--;
        cartaAPersona[_tokenId] = _to;
        Transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) public override soloDuenioDe(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public override soloDuenioDe(_tokenId) {
        cartaApprovals[_tokenId] = _to;
        Approval(msg.sender, _to, _tokenId);
    }

    function takeOwnership(uint256 _tokenId) public override {
        require(cartaApprovals[_tokenId] == msg.sender);
        address owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }
}