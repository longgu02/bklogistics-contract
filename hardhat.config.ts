require("dotenv").config();
// require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");

// Go to https://infura.io, sign up, create a new API key
// in its dashboard, and replace "KEY" with it
const INFURA_API_KEY = "KEY";

// Replace this private key with your Sepolia account private key
// To export your private key from Coinbase Wallet, go to
// Settings > Developer Settings > Show private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Beware: NEVER put real Ether into testing accounts

module.exports = {
	solidity: "0.8.9",
	networks: {
		goerli: {
			url: `https://eth-goerli.g.alchemy.com/v2/${process.env.GOERLI_PRIVATE_KEY}`,
			accounts: [process.env.ACCOUNT],
		},
	},
};
