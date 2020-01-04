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

		ch1 = await contractInstance.dogsById(1)
		balance = await contractInstance.balanceOf(accounts[1])
		assert.equal(ch1.category,2)
		assert.equal(balance,1)
	}

	)
	
	
	it('should not create a dog twice for the same address', async () => {

		await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})

		await tryCatch(contractInstance.declareAnimal(accounts[1],5,1,0,1, {from :accounts[1]}), errTypes.revert)

	}

	)
	
	
	
	it('should not burn token if not owner', async() => {
		
		await contractInstance.declareAnimal(accounts[1],race,isMale,age,category, {from :accounts[1]})	
		
		await tryCatch(contractInstance.deadAnimal(1, {from : accounts[2]}), errTypes.revert)
			
	})
	

 
    it('should not declare animal if breeder address is not sender',async() => {
		
		await tryCatch(contractInstance.declareAnimal(accounts[1],0,0,0,0, {from: accounts[2]}), errTypes.revert)
})




})