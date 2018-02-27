var CopyRightContract = artifacts.require("./CopyRightContract.sol");

contract("CopyRightContract", function(accounts){
	CopyRightContract.deployed().then(function(instance){
		
		instance.verifyBuyerName("aa").then(function(result){
			//console.log(result);
			assert.equal(result, false, "aa should not be verified");
		})

		instance.buy("bb", {value:2e16}).then(function(result){
			//console.log(result.logs);
			assert.equal(result.logs[0].args.buyerName, "bb", "buyerName should be bb");

			instance.verifyBuyerName("bb").then(function(result){
				//console.log(result);
				assert.equal(result, true, "bb should  be verified");
			})
		})		
	})
})