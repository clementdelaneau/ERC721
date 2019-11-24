const AuctionSystem = artifacts.require("./AuctionSystem.sol")
let contractInstance
const PREFIX = "Returned error: VM Exception while processing transaction: ";

contract('managingAuction', accounts => {
	beforeEach('setup contract for each test', async () => {
		contractInstance = await AuctionSystem.new({from : accounts[0]})
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
   
   
   it('should bid', async() => {
   	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})

   	await contractInstance.createAuction(1,5, {from: accounts[1]})
	
   await contractInstance.bidAuction(1, {from : accounts[2], value : 6})
	await contractInstance.bidAuction(1, {from : accounts[3], value : 8})
	
	auction = await contractInstance.auction(1)
	bidderToBid = await contractInstance.bidderToBid(accounts[3])
	
	assert.equal(auction.highestBid, 8)
	assert.equal(bidderToBid, 8)
	   
   })
   
   it('should update bid', async() => {
   	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})

   	await contractInstance.createAuction(1,5, {from: accounts[1]})
	
   await contractInstance.bidAuction(1, {from : accounts[2], value : 6})
	await contractInstance.bidAuction(1, {from : accounts[3], value : 8})	
	await contractInstance.updateBid(1,{from : accounts[2], value : 3})	
	
	auction = await contractInstance.auction(1)
	bidderToBid = await contractInstance.bidderToBid(accounts[2])
	
	assert.equal(auction.highestBid, 9)
	assert.equal(bidderToBid, 9)
	
   })
   
   
   
   
      it('should not claim auction before the end date', async() => {
   	await contractInstance.declareAnimal(accounts[1],0,0,0,0, {from :accounts[1]})
   	await contractInstance.createAuction(1,5, {from: accounts[1]})

   	await contractInstance.bidAuction(1,{from :accounts[2], value: web3.utils.toWei('6', 'wei')})


   try {
	   await contractInstance.claimAuction(1, {from :accounts[2]})
	   assert.fail('expected error not thrown')

   }
   catch(e) {
	   err= "revert auction is not finished yet"
	   assert.equal(e.message, PREFIX + err + " -- Reason given: auction is not finished yet." )
   }

   })
	
	
}
)