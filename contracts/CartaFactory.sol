pragma solidity >=0.7.0 <0.9.0;

/**
 * @title CartaFactory
 * @dev Generacion aleatoria de cartas
 */
contract CartaFactory {
    uint256 semilla = 0;
    uint8 cantidadDigitos = 16;
    uint256 modulo = 10 ** cantidadDigitos;

    struct Carta {
        uint256 descripcion;
    }
    
    Carta[] public cartas;
    
    /**
     * @dev Crea una instancia de carta
     * @param _descripcion descripcion para crear la carta
     */
    function _crearCarta(uint256 _descripcion) private {
        cartas.push(Carta(_descripcion));
    }

    /**
     * @dev Crea un valor aleatorio de descripcion 
     * @return valor aleatorio de descripcion
     */
    function _crearDescripcionAleatoria() private returns (uint256){
        semilla ++;
        uint256 descripcionAleatoria = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, semilla)));
        return descripcionAleatoria % modulo;
    }
    
    /**
     * @dev Crea una carta aleatoria
     */
    function crearCartaAleatoria() public {
        uint256 descripcionAleatoria = _crearDescripcionAleatoria();
        _crearCarta(descripcionAleatoria);
    }
}