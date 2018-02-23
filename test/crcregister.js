var CopyRightContract = artifacts.require("./CopyRightContract.sol");
var CRCRegister = artifacts.require("./CRCRegister.sol");


contract("CRCRegister", function(accounts){
	CRCRegister.deployed().then(function(instance) {
			//console.log(instance);
		instance.register("111", "aaa", 1e16,{from:web3.eth.accounts[0]}).then(function(result){
			instance.updateContractInfo(result.logs[0].args.crContract, "tt", "dd", "kk", "111",{from:web3.eth.accounts[0]}).then(function(r){
				console.log(r.logs);
			});

			crc = new CopyRightContract(result.logs[0].args.crContract);
			crc.buy("bbb", {from:web3.eth.accounts[2], value:2e16}).then(function(r){result = r; console.log(result.logs)});
				
		});	

		instance.list(0,10).then(function(result){
			console.log(result);
		});

		/*instance.listByAuthor(web3.eth.accounts[2], 0,10).then(function(result){
			console.log(result);
		});*/
		/*instance.authorContracts(web3.eth.accounts[2]).then(function(result){
			console.log(result);
		});*/
	})
})






