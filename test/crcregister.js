var CopyRightContract = artifacts.require("./CopyRightContract.sol");
var CRCRegister = artifacts.require("./CRCRegister.sol");
var ChainStockToken = artifacts.require("./ChainStockToken.sol");

function checkAllBalances(cst, register) {
     var totalBal = 0;
     for (var acctNum in web3.eth.accounts) {
         var acct = web3.eth.accounts[acctNum];
         var acctBal = web3.fromWei(web3.eth.getBalance(acct), "ether");
         cst.balanceOf(acct).then(function(an, ac, ab){
         	return function(result){
	         	var acctToken= web3.fromWei(result, "ether");
	         	//totalBal += parseFloat(acctBal);
	         	console.log("  eth.accounts[" + an + "]: \t" + ac + " \tbalance: " + ab + " ether" + "\tCST: " + acctToken);
	         }
         }(acctNum,acct,acctBal));
     }

     var acct = register.address;
     var acctBal = web3.fromWei(web3.eth.getBalance(acct), "ether");
     cst.balanceOf(acct).then(function(result){
         var acctToken= web3.fromWei(result, "ether");
         console.log("  register: \t" + acct + " \tbalance: " + acctBal + " ether" + "\tCST: " + acctToken);
     });
 };


contract("CRCRegister", function(accounts){
	CRCRegister.deployed().then(function(instance) {
		console.log(instance.address)
		ChainStockToken.deployed().then(function(cst) {
			console.log(cst.address);
			checkAllBalances(cst, instance);
			instance.setTokenAddress(cst.address).then(function(result){
					//console.log(result);
				//转token到register
				cst.transfer(instance.address, 5e20).then(function(result){
					console.log("transfer token to register: ");
					//checkAllBalances(cst, instance);
					//console.log(result);
					//注册文件
					instance.register("111", "aaa", 1e16,{from:web3.eth.accounts[0]}).then(function(result){
						//console.log(result.logs[0].args);
						console.log("register one file: ");
						//checkAllBalances(cst, instance);
						crc = result.logs[1].args.crContract;
						instance.updateContractInfo(
							crc, "tt", "dd", "kk", "111",
							{from:web3.eth.accounts[0]}).then(function(r){
							//console.log(r.logs[0].args);
						});

						//购买文件
						crc = new CopyRightContract(crc);
						crc.buy("bbb", {from:web3.eth.accounts[2], value:2e16}).then(function(r){
							//console.log(r.logs[0].args)
							console.log("buy one file with eth: ");
							//checkAllBalances(cst, instance);
						});
					});	

					instance.list(0,10,true).then(function(result){
						//console.log(result);
					});

					//转eth到register
					web3.eth.sendTransaction({from:web3.eth.accounts[5], to:instance.address, value: 1e19}, 
						function(result){
							console.log("send eth to register: ");
							//checkAllBalances(cst, instance);
							instance.buy({from:web3.eth.accounts[6], value:1e19}).then(function(result){
								//console.log(JSON.stringify(result.logs[0]));
								//console.log(JSON.stringify(result.logs[1]));
								console.log("buy token from register: ");
								//checkAllBalances(cst, instance);

								instance.Sell({fromBlock:0}).get(function(err, result){
										//console.log(JSON.stringify(result[0].args));
								});

								instance.GetPrice({fromBlock:0}).get(function(err, result){
										console.log(JSON.stringify(result[0].args));
								});
								cst.approveAndCall(instance.address, 1.2525e19, [], {from:web3.eth.accounts[6]}).then(function(result){
									//console.log(JSON.stringify(result.logs[0]));
									//console.log(JSON.stringify(result.logs[1]));
									console.log("sell token to register: ");
									checkAllBalances(cst, instance);
								});
							});

							
					});					
				});
				
			});
			
			/*instance.listByAuthor(web3.eth.accounts[2], 0,10).then(function(result){
				console.log(result);
			});*/
			/*instance.authorContracts(web3.eth.accounts[2]).then(function(result){
				console.log(result);
			});*/
		})
	})
})






