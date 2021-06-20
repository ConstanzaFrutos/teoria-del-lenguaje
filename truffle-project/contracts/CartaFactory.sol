pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

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

    uint256 public cantidadCartas = 0;

    /**
    * Tipos:
    * 1: normal
    * 2: rara
    * 3: epica
    */
    struct Carta {
        uint256 descripcion;
        uint8 tipo;
    }
    
    Carta[] public cartas;

    mapping (uint => address) public cartaAPersona;
    mapping (address => uint) personaCantidadCartas;
    
    /**
     * @dev Crea una instancia de carta
     * @param _descripcion descripcion para crear la carta
     */
    function _crearCarta(uint256 _descripcion, uint8 _tipo) private {
        uint id = cartas.push(Carta(_descripcion, _tipo)) - 1;
        cartaAPersona[id] = msg.sender;
        personaCantidadCartas[msg.sender] ++;
        cantidadCartas ++;
        emit NuevaCarta(id, _descripcion, _tipo);
    }

    /**
     * @dev Crea un valor aleatorio de descripcion 
     * @return valor aleatorio de descripcion
     */
    function _crearDescripcionAleatoria() private returns (uint256){
        semillaDescripcion ++;
        uint256 descripcionAleatoria = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, semillaDescripcion)));
        return descripcionAleatoria % modulo;
    }

    /**
     * @dev Crea un tipo de carta aleatorio
     * @return valor aleatorio de tipo de carta
     */
    function _crearTipoAleatorio() private returns (uint8){
        semillaTipo ++;
        uint256 tipoAleatorio = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, semillaTipo)));
        return uint8(tipoAleatorio % cantidadTipos);
    }
    
    /**
     * @dev Crea una carta aleatoria
     */
    function crearCartaAleatoria() public {
        uint256 descripcionAleatoria = _crearDescripcionAleatoria();
        uint8 tipoAleatorio = _crearTipoAleatorio();
        _crearCarta(descripcionAleatoria, tipoAleatorio);
    }

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
        uint256[] memory descripciones = new uint256[](personaCantidadCartas[_owner]);
        uint8[] memory tipos = new uint8[](personaCantidadCartas[_owner]);

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
