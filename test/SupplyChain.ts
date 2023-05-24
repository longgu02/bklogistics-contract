import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import "@nomicfoundation/hardhat-chai-matchers"; //Added for revertWithCustomErrors
import { expect } from "chai";
import { BigNumber, constants } from "ethers";
import hre from "hardhat";

export const ADMIN_ROLE =
	"0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42";
export const CARRIER_ROLE =
	"0xeb998ffefd22a823ed46d63e27357a1eefa908b6ba6804ac328694f77956b469";
export const MEMBER_ROLE =
	"0xffa60083152bd11704a80cc8c7a409dad8aa74288b454a3ba0e94c0abc7cf168";

describe("Supply Chain", function () {
	// We define a fixture to reuse the same setup in every test.
	// We use loadFixture to run this setup once, snapshot that state,
	// and reset Hardhat Network to that snapshot in every test.
	async function deploy() {
		// Contracts are deployed using the first signer/account by default
		const [owner, otherAccount1, otherAccount2, otherAccount3] =
			await hre.ethers.getSigners();
		// console.log("Owner", owner.getBalance);
		// console.log("Account1", await otherAccount1.getBalance());
		// console.log("Account2", await otherAccount2.getBalance());
		// console.log("Account3", await otherAccount3.getBalance());
		const Roles = await hre.ethers.getContractFactory("Roles");
		const Product = await hre.ethers.getContractFactory("Products");
		const SupplyChain = await hre.ethers.getContractFactory("SupplyChain");
		const roleContract = await Roles.deploy();
		const productContract = await Product.deploy();
		await roleContract.deployed();
		await productContract.deployed();

		const supplyChainContract = await SupplyChain.deploy(
			roleContract.address,
			productContract.address
		);

		await supplyChainContract.deployed();
		return {
			owner,
			otherAccount1,
			otherAccount2,
			otherAccount3,
			supplyChainContract,
			roleContract,
			productContract,
		};
	}

	describe("Supply Chain Deployment", function () {
		it("Should add admin role to the deployer", async function () {
			const { owner, roleContract } = await loadFixture(deploy);
			expect(await roleContract.hasRole(ADMIN_ROLE, owner.address)).equal(true);
		});
	});

	describe("Create order", function () {
		it("Should create order and emit event", async function () {
			const {
				owner,
				otherAccount1,
				otherAccount2,
				otherAccount3,
				supplyChainContract,
				productContract,
				roleContract,
			} = await loadFixture(deploy);
			await roleContract.addMember(otherAccount1.address);
			await productContract.addProduct("Bim bim");
			const _receipt = await otherAccount1.call(
				supplyChainContract.createOrder(
					1,
					otherAccount1.address,
					[otherAccount2.address],
					[otherAccount3.address]
				)
			);
			console.log(_receipt);
			expect(
				await otherAccount1.call(
					supplyChainContract.createOrder(
						1,
						otherAccount1.address,
						[otherAccount2.address],
						[otherAccount3.address]
					)
				)
			).to.be.revertedWith("a supplier is not a member");
		});
	});
});
