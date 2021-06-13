var CartaFactory = artifacts.require("CartaFactory");

module.exports = function(deployer) {
  deployer.deploy(CartaFactory);
};