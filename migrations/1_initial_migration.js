var Migrations = artifacts.require("./Migrations.sol");
var CopyRightContract = artifacts.require("./CopyRightContract.sol");
var CRCRegister = artifacts.require("./CRCRegister.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(Migrations);
  deployer.deploy(CopyRightContract, "1", accounts[2], "author", 1e16);
  deployer.deploy(CRCRegister);
};
