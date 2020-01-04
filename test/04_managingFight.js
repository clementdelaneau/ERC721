const Arena = artifacts.require("./Arena.sol")
let contractInstance

contract('managingFight', accounts => {
	beforeEach('setup contract for each test', async () => {
		contractInstance = await Arena.new({from : accounts[0]})
	})
	
	
	
	it('should pocess a fight', async() => {
     	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})
		await contractInstance.declareAnimal(accounts[2],1,1,0,3, {from :accounts[2]})


		await contractInstance.proposeToFight(1, 2, {from : accounts[1], value : 10})
		await contractInstance.agreeToFight(1, {from : accounts[2], value : 10})

		
		fight = await contractInstance.fightsById(1)


		assert.equal(fight.dog1, 1)
		assert.equal(fight.dog2,2)
		assert.equal(fight.accepted, true)


	})
	
	
})