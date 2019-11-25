const DogCore = artifacts.require("./DogCore.sol")

module.exports = function(deployer) {
	deployer.deploy(DogCore);
};

