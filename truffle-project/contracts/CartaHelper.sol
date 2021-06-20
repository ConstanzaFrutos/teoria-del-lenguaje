pragma solidity 0.5.16;

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
        uint256[] memory descripciones = new uint256[](cantidadCartas);
        uint8[] memory tipos = new uint8[](cantidadCartas);
        for (uint i = 0; i < cantidadCartas; i++) {
            descripciones[i] = (cartas[i].descripcion);
            tipos[i] = (cartas[i].tipo);
        }
        return (descripciones, tipos);
    }

    /**
     * Para obtener todas las cartas correspondientes a un address
     */
    function getCartasDe(address _owner) external view returns (uint256[] memory, uint8[] memory) {
        uint256[] memory descripciones = new uint256[](cantidadCartas);
        uint8[] memory tipos = new uint8[](cantidadCartas);

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