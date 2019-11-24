const Arena = artifacts.require("./Arena.sol")

module.exports = function(deployer) {
	deployer.deploy(Arena);
};

