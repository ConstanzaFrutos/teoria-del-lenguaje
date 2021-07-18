// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./CartaHelper.sol";
import "./erc721.sol";
import "./IOzToken.sol";

interface ISubastaFactory {
    function crearSubasta(address _duenio, uint _idCarta, uint _incrementoOferta, uint _tiempoInicial, uint _tiempoFinal) external returns(uint);
    function cancelarSubasta(uint _idSubasta, address _cuenta ) external returns (bool success);
    function retirarFondos(uint _idSubasta, address _cuenta ) external returns (uint cantidadARetirar);
    function ofertar(uint _idSubasta, uint _amount , address _cuenta ) external returns (bool success);
    function getIdCartaEnSubasta(uint _idSubasta) external returns(uint);
}

/**
 * @title CartaItem
 * @dev Funciones de administracion de cartas como 
 * compra de las mismas o transferencia de ownership
 */
contract CartaItem is CartaHelper, ERC721, ERC721Metadata {

    IOzToken ozContract;
    
    ISubastaFactory subastaFactory;

    uint costoCarta = 5;
    uint costoTransferencia = 3;
    uint comisionTransferencia = 1;
    uint costoSubastarCarta = 3;
    address ozAccount = 0x1C53954455A6796723B52021c034964DD9E329dE;

    mapping (uint => address) cartaApprovals;

    constructor(address _ozAddress, address _subastaFactoryAddress , address _ozAccount) public ERC721Metadata("CartaItem", "CITM") {
        ozContract = IOzToken(_ozAddress);
        subastaFactory = ISubastaFactory(_subastaFactoryAddress);
        ozAccount = _ozAccount;
    }

    /**
     * @dev Crea una carta aleatoria
     * @return id de la carta creada
     */
    function crearCartaAleatoria() public returns (uint256) {
        require(msg.sender != address(0), "Error: direccion cero creando carta");
        require(ozContract.balanceOf(msg.sender) >= costoCarta, "No tiene saldo suficiente para realizar la carta");
        ozContract.transferFrom(msg.sender, ozAccount, costoCarta);
        uint256 descripcionAleatoria = _crearDescripcionAleatoria();
        uint8 tipoAleatorio = _crearTipoAleatorio();
        _crearCarta(descripcionAleatoria, tipoAleatorio);
        emit Transfer(address(0), msg.sender, 1);
        return cartas.length - 1;
    }

    // Funciones subasta

    /**
     * @dev Se subasta una carta
     * @return id de la subasta
     */
    function subastarCarta(address _duenio, uint _idCarta, uint _incrementoOferta, uint _tiempoInicial, uint _tiempoFinal) public
    soloDuenioDe(_idCarta) cartaNoEnSubasta(_idCarta) cartaExiste(_idCarta) returns (uint) {
        require(msg.sender != address(0), "Error: direccion cero subastando carta");
        require(ozContract.balanceOf(msg.sender) >= costoSubastarCarta, "No tiene saldo suficiente para subastar la carta");
        uint idSubasta = subastaFactory.crearSubasta(_duenio, _idCarta, _incrementoOferta, _tiempoInicial, _tiempoFinal);
        ozContract.transferFrom(msg.sender, ozAccount, costoSubastarCarta);
        Carta storage carta = cartas[_idCarta];
        carta.enSubasta = true;
        return idSubasta;
    }

    function ofertarCarta(uint _idSubasta, uint _amount) public returns(bool) {
        require(_amount > 0, "Se debe ofertar una cantidad positiva");
        require(ozContract.balanceOf(msg.sender) >= _amount, "No tiene saldo suficiente para ofertar");
        require(subastaFactory.ofertar(_idSubasta, _amount, msg.sender), "No se pudo ofertar en esta subasta");
        ozContract.transferFrom(msg.sender, ozAccount, _amount);
        return true;
    }

    function retirarFondos(uint _idSubasta) public returns(bool) {
        uint cantidadARetirar = subastaFactory.retirarFondos(_idSubasta, msg.sender);
        ozContract.transferFrom(ozAccount,msg.sender, cantidadARetirar);
        return true;
    }

    function cancelarSubasta(uint _idSubasta) public returns(bool) {
        bool _cancelarSubasta = subastaFactory.cancelarSubasta(_idSubasta, msg.sender);
        uint _idCarta = subastaFactory.getIdCartaEnSubasta(_idSubasta);
        Carta storage carta = cartas[_idCarta];
        carta.enSubasta = _cancelarSubasta;
        return _cancelarSubasta;
    }

    // Implementacion ERC721

    function balanceOf(address _owner) public view override returns(uint256 _balance) {
        return personaCantidadCartas[_owner];
    }

    function ownerOf(uint256 _tokenId) public view override returns(address _owner) {
        return cartaAPersona[_tokenId];
    }

    /**
     * @dev Se transfiere una carta determinada
     * @param _from dueño actua de la carta, quien recibe OZT a cambio de la carta
     * @param _to quien paga la transferencia y quiere obtener la carta
     * @param _tokenId el id de la carta a transferir
     */
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        require(ozContract.balanceOf(_to) >= costoTransferencia, "No tiene saldo suficiente para realizar la transferencia");
        ozContract.transferFrom(_to, _from, costoTransferencia);
        ozContract.transferFrom(_from, ozAccount, comisionTransferencia); // Comision
        
        personaCantidadCartas[_to]++;
        personaCantidadCartas[_from]--;
        cartaAPersona[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) public override soloDuenioDe(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public override soloDuenioDe(_tokenId) {
        cartaApprovals[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function takeOwnership(uint256 _tokenId) public override {
        require(cartaApprovals[_tokenId] == msg.sender);
        address owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }

    // Funciones OzToken

    function balanceOzToken() external view returns (uint) {
        return ozContract.balanceOf(msg.sender);
    }

    // Uso de contratos externos

    /**
     * @dev Para cambiar la direccion del contrato OzToken
     */
    function setOzTokenAddress(address _ozTokenAddress) public onlyOwner {
        ozContract = IOzToken(_ozTokenAddress);
    }

    /**
     * @dev Para cambiar la direccion del contrato de subasta factory
     */
    function setSubastaFactoryAddress(address _subastaFactoryAddress) public onlyOwner {
        subastaFactory = ISubastaFactory(_subastaFactoryAddress);
    }

    // Cuenta de destino de fondos

    /**
     * @dev Se setea la cuenta a la cual se le va a depositar el pago     
     */
    function setOzAccountAddress(address _ozAccountAddress) public onlyOwner {
        ozAccount = _ozAccountAddress;
    }
}