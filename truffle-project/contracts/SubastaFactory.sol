pragma solidity ^0.8.0;
import {Subasta} from './subasta.sol';


contract SubastaFactory {
    uint public idSubasta;
    mapping(uint256 => Subasta) public subastas; 
    //address[] public subastasDisponibles;
    
    event SubastaCreada(Subasta contratoSubasta, address duenio, uint idSubasta);

    constructor(){
        idSubasta = 0;
    }

    function subastaFactory() public {
    }

    function crearSubasta(uint incrementoOferta, uint tiempoInicial, uint tiempoFinal) public {
        Subasta nuevaSubasta = new Subasta(msg.sender, incrementoOferta, tiempoInicial, tiempoFinal);
        subastas[idSubasta];
        idSubasta ++;
        SubastaCreada(nuevaSubasta, msg.sender, idSubasta);
    }

    function getSubasta(uint _id) view public returns (Subasta){
        return subastas[_id];
    }

    function getIdSubastasDisponibles() view public returns(uint[] memory){
        uint[] memory subastasDisponibles = new uint[](idSubasta);
        for(uint i = 0; i < idSubasta; i++){
            if(!subastas[i].estaCancelada()){
                subastasDisponibles[i] = i;
            }
        }
        return subastasDisponibles;
    } 
}



