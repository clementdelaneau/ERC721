const AuctionSystem = artifacts.require("./AuctionSystem.sol")
let contractInstance
//const MockTime = artifacts.require("./MockTime")
//let time 
let tryCatch = require("./exceptions.js").tryCatch;
let errTypes = require("./exceptions.js").errTypes;
	
contract('managingAuction', accounts => {
	beforeEach('setup contract for each test', async () => {
		contractInstance = await AuctionSystem.new({from : accounts[0]})
		//time = await MockTime.new()
	})
	
   it('should create auction', async() => {
   	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})

   	await contractInstance.createAuction(1,5, {from: accounts[1]})


   	dogInAuction = await contractInstance.dogsInAuction(1)
	auction = await contractInstance.auction(1)

   	assert.isTrue(dogInAuction)
	assert.equal(auction.chairperson, accounts[1])
	assert.equal(auction.startingPrice, 5)
	assert.equal(auction.highestBid, 5)
	assert.equal(auction.winner, "0x0000000000000000000000000000000000000000")

   })
   
   it('should not create auction if not token owner', async() => {
   	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})
    await tryCatch(contractInstance.createAuction(1,5, {from : accounts[2]}), errTypes.revert)
   })
   
   
   
   it('should not create auction if dog already in auction', async() => {
	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})
   	await contractInstance.createAuction(1,5, {from: accounts[1]})
	
	await tryCatch(contractInstance.createAuction(1,5, {from: accounts[1]}), errTypes.revert)
		
   })
   
   
   
   
   it('should bid', async() => {
   	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})

   	await contractInstance.createAuction(1,5, {from: accounts[1]})
	
   await contractInstance.bidAuction(1, {from : accounts[2], value : 6})
	await contractInstance.bidAuction(1, {from : accounts[3], value : 8})
	
	auction = await contractInstance.auction(1)
	bidderToBid = await contractInstance.getBid({from : accounts[3]})
	
	assert.equal(auction.highestBid, 8)
	assert.equal(bidderToBid, 8)
	   
   })
   
   
      it('should not bid on its own auction', async() => {
   	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})

   	await contractInstance.createAuction(1,5, {from: accounts[1]})
	
   await tryCatch(contractInstance.bidAuction(1, {from : accounts[1], value : 6}),errTypes.revert)

	   
   })
   
   it('should update bid', async() => {
   	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})

   	await contractInstance.createAuction(1,5, {from: accounts[1]})
	
   await contractInstance.bidAuction(1, {from : accounts[2], value : 6})
	await contractInstance.bidAuction(1, {from : accounts[3], value : 8})	
	await contractInstance.updateBid(1,{from : accounts[2], value : 3})	
	
	auction = await contractInstance.auction(1)
	bidderToBid = await contractInstance.getBid({from : accounts[2]})
	
	assert.equal(auction.highestBid, 9)
	assert.equal(bidderToBid, 9)
	
   })
   
   
   
   
      it('should not claim auction before the end date', async() => {
   	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})
   	await contractInstance.createAuction(1,5, {from: accounts[1]})

   	await contractInstance.bidAuction(1,{from :accounts[2], value: web3.utils.toWei('6', 'wei')})
    
	await tryCatch(contractInstance.claimAuction(1, {from :accounts[2]}), errTypes.revert)

   })
   
   /*
   it('winner should claim auction after the end date', async() => {
	   	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})
   	await contractInstance.createAuction(1,50000, {from: accounts[1]})

   	await contractInstance.bidAuction(1,{from :accounts[2], value: web3.utils.toWei('600000', 'wei')})   
	await contractInstance.setBlockTime(1680169600)
	await contractInstance.claimAuction(1, {from: accounts[2]})
   })*/
	
	
}
)