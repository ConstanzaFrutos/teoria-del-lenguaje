var CartaItem = artifacts.require("CartaItem");

module.exports = function(deployer) {
  deployer.deploy(CartaItem);
};