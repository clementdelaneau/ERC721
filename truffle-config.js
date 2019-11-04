//require('dotenv').config();

//const HDWalletProvider = require('truffle-hdwallet-provider');

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 7545,
      network_id: '5777' // Match any network id
    }
  /*
    ropsten: {
      provider: () => new HDWalletProvider(process.env.MNEMONIC, "https://ropsten.infura.io/v3/" + process.env.INFURA_API_KEY),
      network_id: 3,   
      gas: 4000000
    }*/
  
  }
	
}