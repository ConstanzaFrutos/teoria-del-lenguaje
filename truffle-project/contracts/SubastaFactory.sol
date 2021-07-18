pragma solidity ^0.8.0;

import "./ozToken.sol";
import "./IOzToken.sol";

contract SubastaFactory {
    uint public idSubasta;
    Subasta[] public subastas;
    IOzToken ozContract;
    address owner;
    
    constructor(address _ozAddress){
        idSubasta = 0;
        ozContract = IOzToken(_ozAddress);
        owner = msg.sender;
    }

    struct Subasta{
        uint id; // identificador de la subasta
        address duenio; // duenio del objeto a subastar
        uint idCarta; // id carta a ofertar
        uint tiempoInicial; //tiempo de comienzo de la subasta
        uint tiempoFinal;  // tiempo de fin de la subasta
        uint incrementoOferta; //incremento minimo entre ofertas
        bool cancelada; //estado de la subasta: cancelada o no.
        address mejorLicitador; //Licitador que dio la mejor oferta

        uint  maximaOfertaLicitador; //esta es complicada, ejemplo:500 pesos.
        bool duenioRetiroDinero; //estado del duenio: si retiro el dinero ganado o no.
        mapping(address => uint256)  ofertasLicitadores; //Hash-> licitadores-ofertas
    }

    event RegistrarOferta(address licitador, uint oferta, address mejorLicitador);
    event RegistrarRetiro(address licitadorRetirado, address cuentaLicidatorRetirado, uint oferta);
    event RegistroCancelacion();

    function crearSubasta (address _duenio, uint _idCarta, uint _incrementoOferta, uint _tiempoInicial, uint _tiempoFinal) public returns(uint){
        require (_tiempoInicial <= _tiempoFinal, "El tiempo inicial deberia ser menor al tiempo final") ;
        require (_tiempoInicial <= block.number);
        require (_duenio != address(0), "Se necesita una cuenta para iniciar una subasta.");
        subastas.push();
        modificarSubasta(_duenio, _idCarta, _incrementoOferta, _tiempoInicial, _tiempoFinal);
        uint idNuevaSubasta = idSubasta;
        idSubasta ++;
        return idNuevaSubasta;
    }

    function modificarSubasta (address _duenio, uint _idCarta, uint _incrementoOferta, uint _tiempoInicial, uint _tiempoFinal) public{
        Subasta storage subasta = subastas[idSubasta];
        subasta.id = idSubasta;
        subasta.duenio = _duenio;
        subasta.idCarta = _idCarta;
        subasta.incrementoOferta = _incrementoOferta;
        subasta.tiempoInicial = _tiempoInicial;
        subasta.tiempoFinal = _tiempoFinal;
        subasta.cancelada = false;
        subasta.maximaOfertaLicitador = 0;
        subasta.duenioRetiroDinero = false;
    }

    function getIdSubastasDisponibles() view public returns(uint[] memory){
        uint[] memory subastasDisponibles = new uint[](idSubasta);
        for(uint i = 0; i < idSubasta; i++){
            if(!estaCancelada(i)){
                subastasDisponibles[i] = i;
            }
        }
        return subastasDisponibles;
    }

    function setTokenAdress(address _ozAddress) public payable returns(bool){
        require(msg.sender == owner, "Solo el OWNER puede cambiar el Token.");
        ozContract = IOzToken(_ozAddress);
        return true;
    }

    function getIdCartaEnSubasta(uint _idSubasta) view public returns(uint){
        return subastas[_idSubasta].idCarta;
    }

    function obtenerOfertaMaxima(uint _idSubasta) public view returns(uint){
        Subasta storage subasta = subastas[_idSubasta];
        return subasta.maximaOfertaLicitador;
    }

    function obtenerMejorLicitador(uint _idSubasta) public view returns(address){
        Subasta storage subasta = subastas[_idSubasta];
        return subasta.mejorLicitador;
    }

    function estaCancelada(uint _idSubasta) public view returns(bool){
        Subasta storage subasta = subastas[_idSubasta];
        return subasta.cancelada;
    }

    function ofertar(uint _idSubasta, uint _amount , address _cuenta) public payable soloDespuesDelComienzo(_idSubasta) soloAntesDelFin(_idSubasta) soloSiNoFueCancelada(_idSubasta)
        soloSiNoEsduenio(_idSubasta, _cuenta) returns (bool success){

        Subasta storage subasta = subastas[_idSubasta];
        uint cantidadOferta = _amount;
        address cuentaOferta = _cuenta;
        
        require(ozContract.balanceOf(cuentaOferta) >= cantidadOferta, "No tiene saldo suficiente para realizar la oferta");

        uint totalNuevaOferta = subasta.ofertasLicitadores[cuentaOferta] + _amount;
        
        //Si la oferta entrante no supera la maxima oferta de otro licitador, rechazamos la oferta. 
        require (totalNuevaOferta >= subasta.maximaOfertaLicitador, "Su oferta debe superar la maxima actual");

        //Le asigno al licitador su nueva oferta
        subasta.ofertasLicitadores[cuentaOferta] = totalNuevaOferta;

        uint ofertaMaxima = subasta.ofertasLicitadores[subasta.mejorLicitador];

        if (totalNuevaOferta <= ofertaMaxima) {
            subasta.maximaOfertaLicitador = _calcularMinimo(totalNuevaOferta + subasta.incrementoOferta, ofertaMaxima);
        } else {
            if(msg.sender != subasta.mejorLicitador){
                subasta.mejorLicitador = _cuenta;
                subasta.maximaOfertaLicitador = _calcularMinimo(totalNuevaOferta, ofertaMaxima + subasta.incrementoOferta);
            }
            ofertaMaxima = totalNuevaOferta;
        }

        ozContract.transferFrom(cuentaOferta, address(this), cantidadOferta);
        emit RegistrarOferta(cuentaOferta,totalNuevaOferta, subasta.mejorLicitador);

        return true;
    }

    function retirarFondos(uint _idSubasta , address _cuenta ) public payable soloSiTerminoOCancelada(_idSubasta) returns (uint){

        address cuentaQueRetira;
        uint cantidadARetirar;
        Subasta storage subasta = subastas[_idSubasta];
        require ( subasta.cancelada , "No puede retirar sus fondos hasta que no termine la subasta");
        if(subasta.cancelada){ //si la subasta fue cancelada, todos pueden retirar sus ofertas.
            cuentaQueRetira = _cuenta;
            cantidadARetirar = subasta.ofertasLicitadores[cuentaQueRetira];

        }else{ // La subasta termino correctamente (alguien gano)   
            if(_cuenta == subasta.duenio){ //el duenio tiene que poder retirar el dinero ganado en la subasta
                cuentaQueRetira = subasta.duenio;
                cantidadARetirar = subasta.maximaOfertaLicitador;
                subasta.duenioRetiroDinero = true;
            }else if(_cuenta == subasta.mejorLicitador){ //el ganador de la subasta puede retirar la diferencia entre la oferta ganadora y oferta maxima.
                cuentaQueRetira = subasta.mejorLicitador;
                cantidadARetirar = subasta.ofertasLicitadores[subasta.mejorLicitador] - subasta.maximaOfertaLicitador;
            }else{ // cualquiera que participo y no gano puede retirar su oferta. 
                cuentaQueRetira = _cuenta;
                cantidadARetirar = subasta.ofertasLicitadores[cuentaQueRetira];
            }
        }
        require ( cantidadARetirar == 0, "No hay dinero disponible para retirar");
        subasta.ofertasLicitadores[cuentaQueRetira] -= cantidadARetirar;

        //require (!payable(msg.sender).send(cantidadARetirar), "Hubo un error al retirar la oferta.");
        ozContract.transferFrom(address(this), _cuenta, cantidadARetirar);
        emit RegistrarRetiro(_cuenta, cuentaQueRetira, cantidadARetirar);
        return cantidadARetirar;
    }

    function cancelarSubasta(uint _idSubasta , address _cuenta) public soloSiEsduenio(_idSubasta, _cuenta) soloAntesDelFin(_idSubasta) soloSiNoFueCancelada(_idSubasta)
    returns (bool success){
        Subasta storage subasta = subastas[_idSubasta];
        subasta.cancelada = true;
        emit RegistroCancelacion();
        return subasta.cancelada;
    }

    function _calcularMinimo(uint a, uint b) private pure returns (uint){
        if (a < b) return a;
        return b;
    }

    modifier soloSiEsduenio(uint _idSubasta, address _cuenta){
        Subasta storage subasta = subastas[_idSubasta];
        require (_cuenta == subasta.duenio, "Solo el duenio puede realizar esta accion.");
        _;
    }

    modifier soloSiNoEsduenio(uint _idSubasta, address _cuenta){
        Subasta storage subasta = subastas[_idSubasta];
        require ( _cuenta != subasta.duenio, "El duenio de la subasta no puede realizar esta accion.");
        _;
    }

    modifier soloDespuesDelComienzo(uint _idSubasta){
        Subasta storage subasta = subastas[_idSubasta];
        require (block.number > subasta.tiempoInicial, "Esta accion no puede ser realizada hasta que no inicie la subasta.");
        _;
    }

    modifier soloAntesDelFin(uint _idSubasta){
        Subasta storage subasta = subastas[_idSubasta];
        require (block.number < subasta.tiempoFinal, "Esta accion solo se puede realizar durante la subasta.");
        _;
    }

    modifier soloSiNoFueCancelada(uint _idSubasta){
        Subasta storage subasta = subastas[_idSubasta];
        require (!subasta.cancelada , "Esta accion no puede realizarse una vez cancelada la subasta.");
        _;
    }

    modifier soloSiTerminoOCancelada(uint _idSubasta){
        Subasta storage subasta = subastas[_idSubasta];
        require (block.number < subasta.tiempoFinal && !subasta.cancelada, "Esta accion no puede realizarse si la subasta esta en curso");
        _;
    }

    
 }

