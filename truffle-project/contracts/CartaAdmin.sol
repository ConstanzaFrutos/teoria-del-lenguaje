pragma solidity ^0.8.0;

import "./CartaFactory.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title CartaAdmin
 * @dev Funciones de administracion de cartas como 
 * compra de las mismas o transferencia de ownership
 */
contract CardItem is CartaFactory, ERC721 {

    constructor() public ERC721("CardItem", "ITM") {}


}