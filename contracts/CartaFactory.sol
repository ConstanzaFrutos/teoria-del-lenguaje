pragma solidity >=0.7.0 <0.9.0;

/**
 * @title CartaFactory
 * @dev Generacion aleatoria de cartas
 */
contract CartaFactory {
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
    function _crearDescripcionAleatoria(string memory _semilla) private pure returns (uint256){
        return uint256(keccak256(abi.encodePacked(_semilla)));
    }
    
    /**
     * @dev Crea una carta aleatoria
     */
    function crearCartaAleatoria(string memory _semilla) public {
        uint256 descripcionAleatoria = _crearDescripcionAleatoria(_semilla);
        _crearCarta(descripcionAleatoria);
    }
}