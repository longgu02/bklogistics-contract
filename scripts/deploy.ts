import hre from "hardhat";
import "@nomiclabs/hardhat-ethers";

async function main() {
	const [deployer] = await hre.ethers.getSigners();

	console.log("Deploying contracts with the account:", deployer.address);

	console.log("Account balance:", (await deployer.getBalance()).toString());

	const Products = await hre.ethers.getContractFactory("Products");
	const Roles = await hre.ethers.getContractFactory("Roles");
	const SBT = await hre.ethers.getContractFactory("BKLogisticsSBT");
	const Shipping = await hre.ethers.getContractFactory("Shipping");
	const SupplyChain = await hre.ethers.getContractFactory("SupplyChain");
	const Pricing = await hre.ethers.getContractFactory("Pricing");

	// const product = await Products.deploy();
	const role = await Roles.deploy();
	// const sbt = await SBT.deploy();
	// await product.deployed();
	await role.deployed();

	// const shipping = await Shipping.deploy(role.address);
	// await shipping.deployed();
	// const supplyChain = await SupplyChain.deploy(role.address, product.address);
	// const pricing = await Pricing.deploy(role.address, product.address);
	// await pricing.deployed();
	// await supplyChain.deployed();
	// await sbt.deployed();

	// console.log("Product address:", product.address);
	console.log("Role address:", role.address);
	// console.log("Shipping address:", shipping.address);
	// console.log("Sbt address:", sbt.address);
	// console.log("Supply Chain address:", supplyChain.address);
	// console.log("Pricing address:", pricing.address);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
