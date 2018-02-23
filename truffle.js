module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
   networks: {
    development: {
      host: "10.2.19.160",
      port: 8545,
      network_id: "*", // Match any network id
      gas: 4600000
    }
  }
};
