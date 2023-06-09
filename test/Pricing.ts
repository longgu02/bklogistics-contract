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

describe("Pricing", function () {
	// We define a fixture to reuse the same setup in every test.
	// We use loadFixture to run this setup once, snapshot that state,
	// and reset Hardhat Network to that snapshot in every test.
	async function deploy() {
		// Contracts are deployed using the first signer/account by default
		const [owner, otherAccount] = await hre.ethers.getSigners();
		const Roles = await hre.ethers.getContractFactory("Roles");
		const role = await Roles.deploy();
		await role.deployed();

		const Product = await hre.ethers.getContractFactory("Products");
		const product = await Product.deploy();
		await product.deployed();

		const Pricing = await hre.ethers.getContractFactory("Pricing");
		const pricing = await Pricing.deploy(role.address, product.address);
		await pricing.deployed();
		await role.addMember(otherAccount.address);
		return { owner, otherAccount, pricing };
	}

	describe("Pricing", function () {
		it("Should add pricing for member", async function () {
			const { owner, otherAccount, pricing } = await loadFixture(deploy);
			expect(
				await otherAccount.call(pricing.modifyPrice(1, 1000000000, 1, 0))
			).to.emit(pricing, "PriceUpdated");
		});
		it("Member should have pricing updated", async function () {
			const { owner, otherAccount, pricing } = await loadFixture(deploy);
			await otherAccount.call(pricing.modifyPrice(1, 1000000000, 0, 0));
			const result = await pricing.getPrice(otherAccount.address, 1, 1);
			console.log(result);
			expect(await pricing.getPrice(otherAccount.address, 1, 1)).to.equal([
				1, 1000000000, 0,
			]);
		});
	});
});
