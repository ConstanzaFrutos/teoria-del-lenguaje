/*var SubastaFactory = artifacts.require("SubastaFactory");
module.exports = function(deployer) {
  deployer.deploy(SubastaFactory, OzToken);
};*/

var OzToken = artifacts.require("OzToken");
var SubastaFactory = artifacts.require("SubastaFactory");

module.exports = function(deployer) {
    deployer.deploy(OzToken)
        .then(() => OzToken.deployed())
        .then(() => deployer.deploy(SubastaFactory, OzToken.address));
}