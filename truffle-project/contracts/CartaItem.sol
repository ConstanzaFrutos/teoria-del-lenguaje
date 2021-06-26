pragma solidity ^0.8.0;

import "./CartaHelper.sol";
import "./erc721.sol";

interface OzInterface {
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}

/**
 * @title CartaItem
 * @dev Funciones de administracion de cartas como 
 * compra de las mismas o transferencia de ownership
 */
contract CartaItem is CartaHelper, ERC721 {

    address ozAddress = 0xC3D1131420135b246B155BA17e32ba9f48c4D6A2;
    OzInterface ozContract = OzInterface(ozAddress);

    uint costoCarta = 2;
    uint costoTransferencia = 1;
    address ozAccount = 0x1C53954455A6796723B52021c034964DD9E329dE;

    mapping (uint => address) cartaApprovals;

    /**
     * @dev Crea una carta aleatoria
     * @return id de la carta creada
     */
    function crearCartaAleatoria() public returns (uint256) {
        require(ozContract.balanceOf(msg.sender) >= costoCarta, "No tiene saldo suficiente para realizar la carta");
        ozContract.transfer(ozAccount, costoCarta);
        uint256 descripcionAleatoria = _crearDescripcionAleatoria();
        uint8 tipoAleatorio = _crearTipoAleatorio();
        _crearCarta(descripcionAleatoria, tipoAleatorio);
        return cartas.length - 1;
    }

    function balanceOf(address _owner) public view override returns (uint256 _balance) {
        return personaCantidadCartas[_owner];
    }

    function ownerOf(uint256 _tokenId) public view override returns (address _owner) {
        return cartaAPersona[_tokenId];
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        require(ozContract.balanceOf(_from) >= costoTransferencia, "No tiene saldo suficiente para realizar la transferencia");
        ozContract.transfer(_to, costoTransferencia);
        ozContract.transfer(ozAccount, costoTransferencia * 0.1); // Comision
        
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

    function balanceOzToken() external view returns (uint) {
        return ozContract.balanceOf(msg.sender);
    }

    function setOzTokenAddress(address _ozTokenAddress) public onlyOwner {
        ozAddress = _ozTokenAddress;
        ozContract = OzInterface(ozAddress);
    }
}