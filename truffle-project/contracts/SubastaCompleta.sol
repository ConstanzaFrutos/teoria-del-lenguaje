pragma solidity ^0.8.0;
import {Subasta} from './subasta.sol';

contract CrearSubasta{

    function CrearSubasta(uint _incrementoOferta, uint _tiempoFinal, uint _tiempoInicial){
        Subasta nuevaSubasta = new Subasta(msg.sender, _incrementoOferta, _tiempoFinal, _tiempoInicial);
    }


}

