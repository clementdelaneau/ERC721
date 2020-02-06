App = {
  web3Provider: null,
  contracts: {},

  init: async function() {


    return await App.initWeb3();
  },

  initWeb3: async function() {
// Modern dapp browsers...
if (window.ethereum) {
  App.web3Provider = window.ethereum;
  try {
    // Request account access
    await window.ethereum.enable();
  } catch (error) {
    // User denied account access...
    console.error("User denied account access")
  }
}
// Legacy dapp browsers...
else if (window.web3) {
  App.web3Provider = window.web3.currentProvider;
}
// If no injected web3 instance is detected, fall back to Ganache
else {
  App.web3Provider = new Web3.providers.HttpProvider('http://localhost:9545');
}
web3 = new Web3(App.web3Provider);

return App.initContract();
},

initContract: function() {
  $.getJSON('DogCore.json', function(data) {
  // Get the necessary contract artifact file and instantiate it with truffle-contract
  var DogCoreArtifact = data;
  App.contracts.DogCore = TruffleContract(DogCoreArtifact);

  // Set the provider for our contract
  App.contracts.DogCore.setProvider(App.web3Provider);


});

  return App.bindEvents();
},



bindEvents: function() {
  $(document).on('click', '.btn-declareAnimal', App.declareAnimal);
  $(document).on('click','.btn-proposeToBreed', App.proposeToBreed);
  $(document).on('click', '.btn-breedAnimal', App.breedAnimal);
  $(document).on('click','.btn-proposeToFight', App.proposeToFight);
  $(document).on('click','.btn-agreeToFight', App.agreeToFight);
  $(document).on('click','.btn-createAuction', App.createAuction);
  $(document).on('click','.btn-bidAuction', App.bidAuction);
  $(document).on('click','.btn-updateBid', App.updateBid);
  $(document).on('click', '.btn-claimAuction', App.claimAuction);
},



proposeToBreed: function() {

  var dogCoreInstance;

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }

    id = document.getElementById("ptb").value;


    var account = accounts[0];


    App.contracts.DogCore.deployed().then(function(instance) {
      dogCoreInstance = instance;

    // Execute adopt as a transaction by sending account
    return dogCoreInstance.proposeToBreed(id, {from : account});
  }).then(function(result) {
    console.log(result);
  }).catch(function(err) {
    console.log(err.message);
  });
});
},



declareAnimal: function(event) {
  event.preventDefault();
  var dogCoreInstance;


  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }


    add = document.getElementById("id1").value;
    r = document.getElementById("id2").value;
    q = document.getElementById("id4").value;
    t = document.getElementById("id5").value;
    var s;

    var radios = document.getElementsByName("gender");
    for(var i =0; i<radios.length;i++) {
      if(radios[i].checked) { 
        s = document.getElementById("male").value;
      }
      else {
        s = document.getElementById("female").value;
      }

    }

    var account = accounts[0];


    App.contracts.DogCore.deployed().then(function(instance) {
      dogCoreInstance = instance;

    // Execute adopt as a transaction by sending account
    return dogCoreInstance.declareAnimal(add,r,s,q,t, {from: account});
  }).then(function(result) {
    console.log(result);
  }).catch(function(err) {
    console.log(err.message);
  });
});



},


breedAnimal: function() {
  var dogCoreInstance;

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }

    id1 = document.getElementById("ba1").value;
    id2 = document.getElementById("ba2").value;


    var account = accounts[0];


    App.contracts.DogCore.deployed().then(function(instance) {
      dogCoreInstance = instance;

    // Execute adopt as a transaction by sending account
    return dogCoreInstance.breedAnimal(id1,id2, {from : account});
  }).then(function(result) {
    console.log(result);
  }).catch(function(err) {
    console.log(err.message);
  });
});

},

proposeToFight: function() {
  var dogCoreInstance;

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }

    id1 = document.getElementById("did1").value;
    id2 = document.getElementById("did2").value;
    value = document.getElementById("bid").value;


    var account = accounts[0];


    App.contracts.DogCore.deployed().then(function(instance) {
      dogCoreInstance = instance;

    // Execute adopt as a transaction by sending account
    return dogCoreInstance.proposeToFight(id1,id2, {from : account, value : value});
  }).then(function(result) {
    console.log(result);
  }).catch(function(err) {
    console.log(err.message);
  });
});


},


agreeToFight: function() {

  var dogCoreInstance;

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }

    id = document.getElementById("fid").value;
    value = document.getElementById("bid2").value;


    var account = accounts[0];


    App.contracts.DogCore.deployed().then(function(instance) {
      dogCoreInstance = instance;

    // Execute adopt as a transaction by sending account
    return dogCoreInstance.agreeToFight(id, {from : account, value : value});
  }).then(function(result) {
    console.log(result);
  }).catch(function(err) {
    console.log(err.message);
  });
});

},


createAuction : function() {

    var dogCoreInstance;

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }

    id = document.getElementById("dogIdAuc").value;
    startingPrice = document.getElementById("startingPrice").value;


    var account = accounts[0];


    App.contracts.DogCore.deployed().then(function(instance) {
      dogCoreInstance = instance;

    // Execute adopt as a transaction by sending account
    return dogCoreInstance.createAuction(id, startingPrice, {from : account});
  }).then(function(result) {
    console.log(result);
  }).catch(function(err) {
    console.log(err.message);
  });
});


},


bidAuction : function() {

  var dogCoreInstance;

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }

    id = document.getElementById("auctionId").value;
    bid = document.getElementById("bidAuc").value;


    var account = accounts[0];


    App.contracts.DogCore.deployed().then(function(instance) {
      dogCoreInstance = instance;

    // Execute adopt as a transaction by sending account
    return dogCoreInstance.bidAuction(id, {from : account, value: bid});
  }).then(function(result) {
    console.log(result);
  }).catch(function(err) {
    console.log(err.message);
  });
});

},


updateBid : function() {

  var dogCoreInstance;

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }

    id = document.getElementById("updateBidAucId").value;
    bid = document.getElementById("bidUpBid").value;


    var account = accounts[0];


    App.contracts.DogCore.deployed().then(function(instance) {
      dogCoreInstance = instance;

    // Execute adopt as a transaction by sending account
    return dogCoreInstance.updateBid(id, {from : account, value: bid});
  }).then(function(result) {
    console.log(result);
  }).catch(function(err) {
    console.log(err.message);
  });
});

},


claimAuction : function() {

    var dogCoreInstance;

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }

    id = document.getElementById("claimAucId").value;

    var account = accounts[0];


    App.contracts.DogCore.deployed().then(function(instance) {
      dogCoreInstance = instance;

    // Execute adopt as a transaction by sending account
    return dogCoreInstance.claimAuction(id, {from : account});
  }).then(function(result) {
    console.log(result);
  }).catch(function(err) {
    console.log(err.message);
  });
});

}

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
