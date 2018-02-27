var ChainStockToken = artifacts.require("./ChainStockToken.sol");


contract("ChainStockToken", function(accounts){
	ChainStockToken.deployed().then(function(instance) {
		instance.balanceOf(web3.eth.accounts[0]).then(function(result){console.log(result)});
	})
})






