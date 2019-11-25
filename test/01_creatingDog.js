const DogRegisterCoin = artifacts.require("./DogRegisterCoin.sol")
let contractInstance

let tryCatch = require("./exceptions.js").tryCatch;
let errTypes = require("./exceptions.js").errTypes;


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
	
	
	it('should burn token only by owner', async() => {
		
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
	
	it('should not burn token if not owner', async() => {
		
		await contractInstance.declareAnimal(accounts[1],race,isMale,age,category, {from :accounts[1]})	
		
		await tryCatch(contractInstance.deadAnimal(1, {from : accounts[2]}), errTypes.revert)
			
	})
	

 
    it('should not declare animal if breeder address is not sender',async() => {
		
		await tryCatch(contractInstance.declareAnimal(accounts[1],0,0,0,0, {from: accounts[2]}), errTypes.revert)
})




})