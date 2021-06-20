var CartaAdmin = artifacts.require("CartaAdmin");
var CartaHelper = artifacts.require("CartaHelper");

module.exports = function(deployer) {
  deployer.deploy(CartaAdmin);
  deployer.deploy(CartaHelper);
};