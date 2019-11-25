require('dotenv').config();

const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 7545,
      network_id: '5777', // Match any network id
	  gas : 8000000,
	  gasPrice : 10000000000
    },
  
    ropsten: {
      provider: () => new HDWalletProvider(process.env.MNEMONIC, "https://ropsten.infura.io/v3/" + process.env.INFURA_API_KEY),
      network_id: 3,   
      gas: 7100000,
	  gasPrice : 10000000000 
    },
	
	rinkeby : {
		provider : () => new HDWalletProvider(process.env.MNEMONIC, "https://rinkeby.infura.io/v3/" + process.env.INFURA_API_KEY),
		network_id : 4,
		gas : 7100000,
		gasPrice : 10000000000
		
  }
	
},

  compilers: {
    solc: { 
      version: "0.5.12", 
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
}


}