pragma solidity >=0.7.0 <0.9.0;

/**
 * @title CartaFactory
 * @dev Generacion aleatoria de cartas
 */
contract CartaFactory {

    event NuevaCarta(uint cartaId, string descripcion);

    uint8 cantidadDigitos = 16;
    uint256 modulo = 10 ** cantidadDigitos;
    uint256 semillaDescripcion = 0;
    uint256 semillaTipo = 0;
    uint8 cantidadTipos = 3;

    struct Carta {
        uint256 descripcion;
        string tipo;
    }
    
    Carta[] public cartas;

    mapping (uint => address) public cartaAPersona;
    mapping (address => uint) personaCantidadCartas;
    
    /**
     * @dev Crea una instancia de carta
     * @param _descripcion descripcion para crear la carta
     */
    function _crearCarta(uint256 _descripcion) private {
        uint id = cartas.push(Carta(_descripcion)) - 1;
        cartaAPersona[id] = msg.sender;
        personaCantidadCartas[msg.sender] ++;
        NuevaCarta(id, _descripcion);
    }

    /**
     * @dev Crea un valor aleatorio de descripcion 
     * @return valor aleatorio de descripcion
     */
    function _crearDescripcionAleatoria() private returns (uint256){
        semillaDescripcion ++;
        uint256 descripcionAleatoria = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, semilla)));
        return descripcionAleatoria % modulo;
    }

    /**
     * @dev Crea un tipo de carta aleatorio
     * @return valor aleatorio de tipo de carta
     */
    function _crearTipoAleatorio() private returns (string){
        semillaTipo ++;
        uint8 tipoAleatorio = uint8(keccak8(abi.encodePacked(block.timestamp, msg.sender, semilla)));
        tipoAleatorio = tipoAleatorio % cantidadTipos;
        if (tipoAleatorio == 1) {
            return "normal";
        } else if (tipoAleatorio == 2) {
            return "rara";
        } else {
            return "epica";
        }
    }
    
    /**
     * @dev Crea una carta aleatoria
     */
    function crearCartaAleatoria() public {
        uint256 descripcionAleatoria = _crearDescripcionAleatoria();
        string tipoAleatorio = _crearTipoAleatorio();
        _crearCarta(descripcionAleatoria, tipoAleatorio);
    }
}
