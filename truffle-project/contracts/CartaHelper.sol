pragma solidity ^0.8.0;

import "./CartaFactory.sol";

/**
 * @title CartaHelper
 * @dev Funciones auxiliares
 */
contract CartaHelper is CartaFactory {

    /**
     * Para obtener todas las cartas
     */
    function getCartas() external view returns (uint256[] memory, uint8[] memory) {
        uint256[] memory descripciones = new uint256[](cartas.length);
        uint8[] memory tipos = new uint8[](cartas.length);
        for (uint i = 0; i < cartas.length; i++) {
            descripciones[i] = (cartas[i].descripcion);
            tipos[i] = (cartas[i].tipo);
        }
        return (descripciones, tipos);
    }

    /**
     * Para obtener todas las cartas correspondientes a un address
     */
    function getCartasDe(address _owner) external view returns (uint256[] memory, uint8[] memory) {
        uint256[] memory descripciones = new uint256[](cartas.length);
        uint8[] memory tipos = new uint8[](cartas.length);

        uint contador = 0;
        for (uint i = 0; i < cartas.length; i++) {
            if (cartaAPersona[i] == _owner) {
                descripciones[contador] = cartas[i].descripcion;
                tipos[contador] = cartas[i].tipo;
                contador ++;
            }
        }
        return (descripciones, tipos);
    }

}