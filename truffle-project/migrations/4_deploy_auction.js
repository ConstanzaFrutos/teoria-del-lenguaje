var Subasta = artifacts.require("Subasta");

_duenio = 0x7d4afE8A39804Fd4b6EE232d8Af5321c0B912D20
_incrementoOferta = 10
_tiempoFinal = 300
_tiempoInicial =  800

module.exports = function(deployer) {
  deployer.deploy(Subasta, _duenio, _incrementoOferta, _tiempoInicial, _tiempoFinal);
};