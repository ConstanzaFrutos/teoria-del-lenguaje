// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CartaFactory
 * @dev Generacion aleatoria de cartas
 */
contract CartaFactory is Ownable {

    event NuevaCarta(uint cartaId, uint256 descripcion, uint8 tipo);

    uint256 cantidadDigitos = 16;
    uint256 modulo = 10 ** cantidadDigitos;
    uint256 semillaDescripcion = 0;
    uint256 semillaTipo = 0;
    uint8 cantidadTipos = 3;

    /**
    * Tipos:
    * 1: normal
    * 2: rara
    * 3: epica
    */
    struct Carta {
        uint256 descripcion;
        uint8 tipo;
        bool enSubasta;
    }
    
    Carta[] public cartas;

    mapping (uint => address) public cartaAPersona;
    mapping (address => uint) personaCantidadCartas;
    
    /**
     * @dev Crea una instancia de carta
     * @param _descripcion descripcion para crear la carta
     */
    function _crearCarta(uint256 _descripcion, uint8 _tipo) internal {
        cartas.push(Carta(_descripcion, _tipo, false));
        uint id = cartas.length - 1;
        cartaAPersona[id] = msg.sender;
        personaCantidadCartas[msg.sender] ++;
        emit NuevaCarta(id, _descripcion, _tipo);
    }

    /**
     * @dev Crea un valor aleatorio de descripcion 
     * @return valor aleatorio de descripcion
     */
    function _crearDescripcionAleatoria() internal returns (uint256){
        semillaDescripcion ++;
        uint256 descripcionAleatoria = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, semillaDescripcion)));
        return descripcionAleatoria % modulo;
    }

    /**
     * @dev Crea un tipo de carta aleatorio
     * @return valor aleatorio de tipo de carta
     */
    function _crearTipoAleatorio() internal returns (uint8){
        semillaTipo ++;
        uint256 tipoAleatorio = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, semillaTipo)));
        return uint8(tipoAleatorio % cantidadTipos);
    }

    modifier soloDuenioDe(uint _cartaId) {
        require (msg.sender == cartaAPersona[_cartaId], "Solo el duenio de la carta puede realizar esta transaccion");
        _;
    }

    modifier cartaNoEnSubasta(uint _cartaId) {
        require (!cartas[_cartaId].enSubasta, "La carta esta siendo subastada");
        _;
    }

    modifier cartaExiste(uint _cartaId) {
        require (_cartaId < cartas.length, "La carta no existe");
        _;
    }

}
