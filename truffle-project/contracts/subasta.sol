pragma solidity ^0.8.0;

//Interfaz
contract Subasta{

    //Datos estaticos - no cambian nunca dentro del SC

    address public duenio; // duenio del objeto a subastar
    uint public tiempoInicial; //tiempo de comienzo de la subasta
    uint public tiempoFinal;  // tiempo de fin de la subasta
    uint public incrementoOferta; //incremento minimo entre ofertas


    //Datos no estaticos - cambian nunca dentro del SC

    bool public cancelada; //estado de la subasta: cancelada o no.
    address public mejorLicitador; //Licitador que dio la mejor oferta
    mapping(address => uint256) public ofertasLicitadores; //Hash-> licitadores-ofertas
    uint public maximaOfertaLicitador; //esta es complicada, ejemplo:500 pesos.
    bool duenioRetiroDinero; //estado del duenio: si retiro el dinero ganado o no.

//licitador = persona que ofrece una cantidad de dinero por un objeto en una subasta

    event RegistrarOferta(address licitador, uint oferta, address mejorLicitador);
    event RegistrarRetiro(address licitadorRetirado, address cuentaLicidatorRetirado, uint oferta);
    event RegistroCancelacion();

    constructor (address _duenio, uint _incrementoOferta, uint _tiempoInicial, uint _tiempoFinal){
        require (_tiempoInicial <= _tiempoFinal, "El tiempo inicial deberia ser menor al tiempo final") ; 
        require (_tiempoInicial <= block.number);
        require (_duenio == address(0), "Se necesita una cuenta para iniciar una subasta."); 

        duenio = _duenio;
        incrementoOferta = _incrementoOferta;
        tiempoInicial = _tiempoInicial;
        tiempoFinal = _tiempoFinal;
    }

//Bueno para comentar las precondiciones antes del codigo.

    function obtenerOfertaMaxima() public view returns(uint){
        return ofertasLicitadores[mejorLicitador];
    }


    function obtenerMejorLicitador() public view returns(address){
        return mejorLicitador;
    }

    function estaCancelada() public view returns(bool){
        return cancelada;
    }


    function ofertar() public payable soloDespuesDelComienzo soloAntesDelFin soloSiNoFueCancelada 
        soloSiNoEsduenio returns (bool success){

        require(msg.value == 0, "Se debe ofertar una cantidad positiva");

        //Cuando oferta de vuelta solo envia la diferencia entre lo que quiere ofertar y lo que oferto previamente. 
        uint totalNuevaOferta = ofertasLicitadores[msg.sender] + msg.value;

        //Si la oferta entrante no supera la maxima oferta de otro licitador, rechazamos la oferta. 
        require (totalNuevaOferta <= maximaOfertaLicitador, "Su oferta debe superar la maxima actual");

        //Le asigno al licitador su nueva oferta
        ofertasLicitadores[msg.sender] = totalNuevaOferta;

        uint ofertaMaxima = ofertasLicitadores[mejorLicitador];

        if(totalNuevaOferta <= ofertaMaxima){
            maximaOfertaLicitador = _calcularMinimo(totalNuevaOferta + incrementoOferta, ofertaMaxima);
        }else{
            if(msg.sender != mejorLicitador){
                mejorLicitador = msg.sender; 
                maximaOfertaLicitador = _calcularMinimo(totalNuevaOferta, ofertaMaxima + incrementoOferta);
            }
            ofertaMaxima = totalNuevaOferta;
        }
        emit RegistrarOferta(msg.sender,totalNuevaOferta, mejorLicitador);
        return true;
    }


    function retirarFondos() public soloSiTerminoOCancelada returns (bool success){
        address cuentaQueRetira;
        uint cantidadARetirar;
        
        if(cancelada){ //si la subasta fue cancelada, todos pueden retirar sus ofertas.
            cuentaQueRetira = msg.sender;
            cantidadARetirar = ofertasLicitadores[cuentaQueRetira];

        }else{ // La subasta termino correctamente (alguien gano)   
            if(msg.sender == duenio){ //el duenio tiene que poder retirar el dinero ganado en la subasta
                cuentaQueRetira = duenio;
                cantidadARetirar = maximaOfertaLicitador; 
                duenioRetiroDinero = true; 
            }else if(msg.sender == mejorLicitador){ //el ganador de la subasta puede retirar la diferencia entre la oferta ganadora y oferta maxima.
                cuentaQueRetira = mejorLicitador;
                cantidadARetirar = ofertasLicitadores[mejorLicitador] - maximaOfertaLicitador;
            }else{ // cualquiera que participo y no gano puede retirar su oferta. 
                cuentaQueRetira = msg.sender;
                cantidadARetirar = ofertasLicitadores[cuentaQueRetira];
            }
        }
        require ( cantidadARetirar == 0, "No hay dinero disponible para retirar"); 
        ofertasLicitadores[cuentaQueRetira] -= cantidadARetirar;

        require (!payable(msg.sender).send(cantidadARetirar), "Hubo un error al retirar la oferta."); 

        emit RegistrarRetiro(msg.sender, cuentaQueRetira, cantidadARetirar);
        return true;
    }


    function cancelarSubasta() public soloSiEsduenio soloAntesDelFin soloSiNoFueCancelada 
    returns (bool success){
        cancelada = true; 
        emit RegistroCancelacion();
        return cancelada;
    }

    function _calcularMinimo(uint a, uint b) private view returns (uint){
        if (a < b) return a;
        return b;
    }

    modifier soloSiEsduenio{
        require (msg.sender != duenio, "Solo el duenio puede realizar esta accion.");
        _;
    }

    modifier soloSiNoEsduenio{
        require (msg.sender == duenio, "El duenio de la subasta no puede realizar esta accion.");
        _;
    }

    modifier soloDespuesDelComienzo{
        require (block.number < tiempoInicial, "Esta accion no puede ser realizada hasta que no inicie la subasta.");
        _;
    }

    modifier soloAntesDelFin{
        require (block.number > tiempoFinal, "Esta accion solo se puede realizar durante la subasta.");
        _;
    }

    modifier soloSiNoFueCancelada{
        require (cancelada, "Esta accion no puede realizarse una vez cancelada la subasta."); 
        _;
    }

    modifier soloSiTerminoOCancelada{
        require (block.number < tiempoFinal && !cancelada, "Esta accion no puede realizarse si la subasta esta en curso");
        _;
    }
    
 }

