pragma solidity ^0.8.0;

import "./CartaHelper.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title CartaItem
 * @dev Funciones de administracion de cartas como 
 * compra de las mismas o transferencia de ownership
 */
contract CartaItem is CartaHelper, ERC721 {

    constructor() public ERC721("CardItem", "CITM") {}

    function awardItem(address _owner) public returns (uint256) {
        personaCantidadCartas[_owner] ++;
        uint _tokenId = crearCartaAleatoria();

        _safeMint(_owner, _tokenId);
        return _tokenId;
    }

    function transferItem(address _to, uint256 _tokenId) public soloDuenioDe(_tokenId) {
        personaCantidadCartas[_to] ++;
        personaCantidadCartas[msg.sender] --;
        cartaAPersona[_tokenId] = _to;
        _transfer(msg.sender, _to, _tokenId);
    }

}