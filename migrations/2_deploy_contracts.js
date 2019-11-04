const DogRegisterCoin = artifacts.require("./DogRegisterCoin.sol")

module.exports = function(deployer) {
	deployer.deploy(DogRegisterCoin);
};

