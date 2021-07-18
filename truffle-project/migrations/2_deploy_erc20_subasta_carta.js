/*var SubastaFactory = artifacts.require("SubastaFactory");
module.exports = function(deployer) {
  deployer.deploy(SubastaFactory, OzToken);
};
var CartaItem = artifacts.require("CartaItem");

module.exports = function(deployer) {
  deployer.deploy(CartaItem);
};*/

var OzToken = artifacts.require("OzToken");
var CartaItem = artifacts.require("CartaItem");
var SubastaFactory = artifacts.require("SubastaFactory");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(OzToken)
        .then(() => OzToken.deployed())
        .then(() => deployer.deploy(SubastaFactory, OzToken.address))
        .then(() => deployer.deploy(CartaItem, OzToken.address, SubastaFactory.address, accounts[1]));
}