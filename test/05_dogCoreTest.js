const DogCoreTest = artifacts.require("./DogCore.sol")
let contractInstance

let tryCatch = require("./exceptions.js").tryCatch;
let errTypes = require("./exceptions.js").errTypes;
	
contract('DogCoreTest', accounts => {
	beforeEach('setup contract for each test', async () => {
		contractInstance = await DogCoreTest.new({from : accounts[0]})
	})
	
	
	it('should send available contract balance to owner', async() => {
	
     // let initBalance
      //let finalBalance	  
      //initialOwnerBalance = web3.eth.getBalance(accounts[0]).then(balance => {console.log(balance)})
		
    web3.eth.sendTransaction({from: accounts[1], to:contractInstance.address, value: web3.utils.toWei('0.2', 'ether'), gasPrice: 10000000000})
   
    initAvailableBalance = await contractInstance.getAvailableBalance({from : accounts[0]})
	contractInstance.withdrawAvailableBalance({from: accounts[0]})
    availableBalance = await contractInstance.getAvailableBalance({from : accounts[0]})

	//newOwnerBalance = web3.eth.getBalance(accounts[0]).then(balance => {console.log(balance)})
	
	assert.equal(web3.utils.fromWei(initAvailableBalance, 'ether'),0.2)
	assert.equal(web3.utils.fromWei(availableBalance, 'ether'),0)
	//assert.isAbove()

	})
	
	it('should not withdraw if not owner', async () => {

        web3.eth.sendTransaction({from: accounts[1], to:contractInstance.address, value: web3.utils.toWei('0.2', 'ether'), gasPrice: 10000000000})
	
		await tryCatch(contractInstance.withdrawAvailableBalance({from : accounts[1]}), errTypes.revert)
	})
	
})
