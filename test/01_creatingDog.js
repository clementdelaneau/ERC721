const DogRegisterCoin = artifacts.require("./DogRegisterCoin.sol")
let contractInstance
//let tryCatch = require("./exceptions.js").tryCatch;
//let errTypes = require("./exceptions.js").errTypes;
//var should = require('chai').should()
//var expect = require('chai').expect()
const PREFIX = "Returned error: VM Exception while processing transaction: ";

contract("CreatingDogs", accounts =>  {
	beforeEach('setup contract for each test', async () => {
		contractInstance = await DogRegisterCoin.new({from:accounts[0]})

	})



	it('should create a dog', async () => {
		race = 0
		isMale =0
		age =0
		category = 2

		await contractInstance.declareAnimal(accounts[1],race,isMale,age,category, {from :accounts[1]})
		await contractInstance.declareAnimal(accounts[1],race,isMale,age,3, {from :accounts[1]})

		ch1 = await contractInstance.dogsById(1)
		breederDogs1 = await contractInstance.breederDogs(accounts[1],0)
		breederDogs2 = await contractInstance.breederDogs(accounts[1],1)
		balance = await contractInstance.balanceOf(accounts[1])
		assert.equal(ch1.category,2)
		assert.equal(breederDogs1.id, 1)
		assert.equal(breederDogs2.id, 2)
		assert.equal(balance,2)
	}

	)
	
	
	it('should burn token', async() => {
		
		await contractInstance.declareAnimal(accounts[1],race,isMale,age,category, {from :accounts[1]})	
		await contractInstance.deadAnimal(1, {from : accounts[1]})

		dog = await contractInstance.dogsById(1)
        balanceOwner = await contractInstance.balanceOf(accounts[1])
        tokenOwner = await contractInstance._tokenOwner(1)		

		assert.equal(dog[0], 0)
		assert.equal(dog[1],0)
		assert.equal(dog[2], 0)
		assert.equal(dog[3], 0)
		assert.equal(dog[4], 0)
		
		assert.equal(balanceOwner, 0)
		
		assert.equal(tokenOwner, "0x0000000000000000000000000000000000000000")

		

	})
	

 
    it('ss',async() => {
		try {
		await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from: accounts[2]})
		assert.fail('expected error not thrown')

		}
		catch(e) {
			err = 'revert breeder address is not correct'
		assert.equal(e.message, PREFIX + err + " -- Reason given: breeder address is not correct." )
}
})




})