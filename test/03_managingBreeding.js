const Breeding = artifacts.require("./Breeding.sol")
let contractInstance

contract('managingBreeding', accounts => {
	beforeEach('setup contract for each test', async () => {
		contractInstance = await Breeding.new({from : accounts[0]})
	})
	
	
	
	
	
	it('should breed a dog when 2 different owners', async() => {
     	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})
		await contractInstance.declareAnimal(accounts[2],1,1,0,3, {from :accounts[2]})


		await contractInstance.proposeToBreed(1, {from : accounts[1]})
		await contractInstance.proposeToBreed(2, {from : accounts[2]})

		await contractInstance.breedAnimal(1,2, {from : accounts[1]})

        dogsInAuction = await contractInstance.dogsInAuction(3)
        auction = await contractInstance.auction(3)


		assert.isTrue(dogsInAuction)
		assert.equal(auction.chairperson, contractInstance.address)


	})
	
	
})