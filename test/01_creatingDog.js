const DogRegisterCoin = artifacts.require("./DogRegisterCoin.sol")
let contractInstance


contract("CreatingDogs", accounts =>  {
	beforeEach('setup contract for each test', async () => {
		contractInstance = await DogRegisterCoin.new({from:accounts[0]})

	})



	it('should create a dog', async () => {
		race = 0
		isMale =0
		age =0
		category = 2

		await contractInstance.declareAnimal(accounts[1],race,isMale,age,category, {from :accounts[1]});
		await contractInstance.declareAnimal(accounts[1],race,isMale,age,3, {from :accounts[1]});

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

/*
	it('should not create a dog if breeder is the 0x0 address', async()=> {

	    return contractInstance.declareAnimal(address(0),race,isMale,age,category, {from : address(0)}).
	    	then(assert.fail).catch(function(error){assert(true);
	    	})


	})*/



	it('should breed a dog', async() => {
		await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]});
		await contractInstance.declareAnimal(accounts[1],1,1,0,3, {from :accounts[1]});


		await contractInstance.proposeToBreed(1, {from : accounts[1]})
		await contractInstance.proposeToBreed(2, {from : accounts[1]})

		await contractInstance.breedAnimal(1,2, {from : accounts[1]})

		breederDogs = await contractInstance.breederDogs(accounts[1],2)
		balance = await contractInstance.balanceOf(accounts[1])




		assert.equal(breederDogs.id, 3)
		assert.equal(breederDogs.race, 5)
		assert.equal(balance,3)


	})


   it('should create auction', async() => {
   	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})

   	await contractInstance.createAuction(1,5, {from: accounts[1]})


   	dogInAuction = await contractInstance.dogsInAuction(1)

   	assert.isTrue(dogInAuction)

   })

/*
   it('should not claim auction before the end date', async() => {
   	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})
   	await contractInstance.createAuction(1,5, {from: accounts[1]})

   	await contractInstance.bidAuction(1,{from :accounts[2], value: web3.utils.toWei('6', 'wei')})


   //	await contractInstance.claimAuction(1, {from: accounts[2]})





   })*/


})