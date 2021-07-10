pragma solidity ^0.8.0;

interface OzInterface {
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}
//Interfaz
contract SubastaFactory{
    address ozAddress = 0xC3D1131420135b246B155BA17e32ba9f48c4D6A2;
    OzInterface ozContract = OzInterface(ozAddress);

    uint public idSubasta;
    Subasta[] public subastas;
    constructor(){
        idSubasta = 0;
    }
    struct Subasta{

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
        Subasta storage subasta = subastas[idSubasta];
        modificarSubasta( _duenio,  _idCarta,  _incrementoOferta,  _tiempoInicial,  _tiempoFinal);
        idSubasta ++;
        return idSubasta;
    }

    function modificarSubasta (address _duenio, uint _idCarta, uint _incrementoOferta, uint _tiempoInicial, uint _tiempoFinal) public{

        Subasta storage subasta = subastas[idSubasta];
        subasta.duenio = _duenio;
        subasta.idCarta = _idCarta;
        subasta.incrementoOferta = _incrementoOferta;
        subasta.tiempoInicial = _tiempoInicial;
        subasta.tiempoFinal = _tiempoFinal;
        subasta.cancelada = false;
        //subasta.mejorLicitador = address(0);
        subasta.maximaOfertaLicitador = 0;
        subasta.duenioRetiroDinero = false;

    }


    //Bueno para comentar las precondiciones antes del codigo.
    /**
     * @dev Para cambiar la direccion del contrato OzToken
     */
    function setOzTokenAddress(address _ozTokenAddress) public onlyOwner {
        ozAddress = _ozTokenAddress;
        ozContract = OzInterface(ozAddress);
    }

    /**
     * @dev Se setea la cuenta a la cual se le va a depositar el pago
     */
    function setOzAccountAddress(address _ozAccountAddress) public onlyOwner {
        ozAccount = _ozAccountAddress;
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


    function ofertar(uint _idSubasta) public payable soloDespuesDelComienzo(_idSubasta) soloAntesDelFin(_idSubasta) soloSiNoFueCancelada(_idSubasta)
        soloSiNoEsduenio(_idSubasta) returns (bool success){

        Subasta storage subasta = subastas[_idSubasta];

        require(msg.value == 0, "Se debe ofertar una cantidad positiva");

        //Cuando oferta de vuelta solo envia la diferencia entre lo que quiere ofertar y lo que oferto previamente. 
        uint totalNuevaOferta = subasta.ofertasLicitadores[msg.sender] + msg.value;

        //Si la oferta entrante no supera la maxima oferta de otro licitador, rechazamos la oferta. 
        require (totalNuevaOferta <= subasta.maximaOfertaLicitador, "Su oferta debe superar la maxima actual");

        //Le asigno al licitador su nueva oferta
        subasta.ofertasLicitadores[msg.sender] = totalNuevaOferta;

        uint ofertaMaxima = subasta.ofertasLicitadores[subasta.mejorLicitador];

        if(totalNuevaOferta <= ofertaMaxima){
            subasta.maximaOfertaLicitador = _calcularMinimo(totalNuevaOferta + subasta.incrementoOferta, ofertaMaxima);
        }else{
            if(msg.sender != subasta.mejorLicitador){
                subasta.mejorLicitador = msg.sender;
                subasta.maximaOfertaLicitador = _calcularMinimo(totalNuevaOferta, ofertaMaxima + subasta.incrementoOferta);
            }
            ofertaMaxima = totalNuevaOferta;
        }
        emit RegistrarOferta(msg.sender,totalNuevaOferta, subasta.mejorLicitador);
        return true;
    }


    function retirarFondos(uint _idSubasta) public soloSiTerminoOCancelada(_idSubasta) returns (bool success){
        address cuentaQueRetira;
        uint cantidadARetirar;
        Subasta storage subasta = subastas[_idSubasta];
        if(subasta.cancelada){ //si la subasta fue cancelada, todos pueden retirar sus ofertas.
            cuentaQueRetira = msg.sender;
            cantidadARetirar = subasta.ofertasLicitadores[cuentaQueRetira];

        }else{ // La subasta termino correctamente (alguien gano)   
            if(msg.sender == subasta.duenio){ //el duenio tiene que poder retirar el dinero ganado en la subasta
                cuentaQueRetira = subasta.duenio;
                cantidadARetirar = subasta.maximaOfertaLicitador;
                subasta.duenioRetiroDinero = true;
            }else if(msg.sender == subasta.mejorLicitador){ //el ganador de la subasta puede retirar la diferencia entre la oferta ganadora y oferta maxima.
                cuentaQueRetira = subasta.mejorLicitador;
                cantidadARetirar = subasta.ofertasLicitadores[subasta.mejorLicitador] - subasta.maximaOfertaLicitador;
            }else{ // cualquiera que participo y no gano puede retirar su oferta. 
                cuentaQueRetira = msg.sender;
                cantidadARetirar = subasta.ofertasLicitadores[cuentaQueRetira];
            }
        }
        require ( cantidadARetirar == 0, "No hay dinero disponible para retirar");
        subasta.ofertasLicitadores[cuentaQueRetira] -= cantidadARetirar;

        require (!payable(msg.sender).send(cantidadARetirar), "Hubo un error al retirar la oferta."); 

        emit RegistrarRetiro(msg.sender, cuentaQueRetira, cantidadARetirar);
        return true;
    }


    function cancelarSubasta(uint _idSubasta) public soloSiEsduenio(_idSubasta) soloAntesDelFin(_idSubasta) soloSiNoFueCancelada(_idSubasta)
    returns (bool success){
        Subasta storage subasta = subastas[_idSubasta];
        subasta.cancelada = true;
        emit RegistroCancelacion();
        return subasta.cancelada;
    }

    function _calcularMinimo(uint a, uint b) private view returns (uint){
        if (a < b) return a;
        return b;
    }

    modifier soloSiEsduenio(uint _idSubasta){
        Subasta storage subasta = subastas[_idSubasta];
        require (msg.sender != subasta.duenio, "Solo el duenio puede realizar esta accion.");
        _;
    }

    modifier soloSiNoEsduenio(uint _idSubasta){
        Subasta storage subasta = subastas[_idSubasta];
        require (msg.sender == subasta.duenio, "El duenio de la subasta no puede realizar esta accion.");
        _;
    }

    modifier soloDespuesDelComienzo(uint _idSubasta){
        Subasta storage subasta = subastas[_idSubasta];
        require (block.number < subasta.tiempoInicial, "Esta accion no puede ser realizada hasta que no inicie la subasta.");
        _;
    }

    modifier soloAntesDelFin(uint _idSubasta){
        Subasta storage subasta = subastas[_idSubasta];
        require (block.number > subasta.tiempoFinal, "Esta accion solo se puede realizar durante la subasta.");
        _;
    }

    modifier soloSiNoFueCancelada(uint _idSubasta){
        Subasta storage subasta = subastas[_idSubasta];
        require (subasta.cancelada, "Esta accion no puede realizarse una vez cancelada la subasta.");
        _;
    }

    modifier soloSiTerminoOCancelada(uint _idSubasta){
        Subasta storage subasta = subastas[_idSubasta];
        require (block.number < subasta.tiempoFinal && !subasta.cancelada, "Esta accion no puede realizarse si la subasta esta en curso");
        _;
    }
    
 }

