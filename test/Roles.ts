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

describe("Roles", function () {
	// We define a fixture to reuse the same setup in every test.
	// We use loadFixture to run this setup once, snapshot that state,
	// and reset Hardhat Network to that snapshot in every test.
	async function deploy() {
		// Contracts are deployed using the first signer/account by default
		const [owner, otherAccount] = await hre.ethers.getSigners();
		const Roles = await hre.ethers.getContractFactory("Roles");
		const role = await Roles.deploy();

		await role.deployed();
		return { owner, otherAccount, role };
	}

	describe("Role Deployment", function () {
		it("Should add admin role to the deployer", async function () {
			const { owner, otherAccount, role } = await loadFixture(deploy);
			expect(await role.hasRole(ADMIN_ROLE, owner.address)).equal(true);
		});
	});

	describe("Member addition", function () {
		it("Should add member role to other account", async function () {
			const { owner, otherAccount, role } = await loadFixture(deploy);
			expect(await role.addMember(otherAccount.address)).to.emit(
				role,
				"MemberAdded"
			);
		});
	});

	describe("Member removal", function () {
		it("Should add member role from other account", async function () {
			const { owner, otherAccount, role } = await loadFixture(deploy);
			await role.addMember(otherAccount.address);
			expect(await role.removeMember(otherAccount.address)).to.emit(
				role,
				"MemberRemoved"
			);
		});
	});

	describe("Carrier addition", function () {
		it("Should add carrier role to other account", async function () {
			const { owner, otherAccount, role } = await loadFixture(deploy);
			expect(await role.addCarrier(otherAccount.address)).to.emit(
				role,
				"CarrierAdded"
			);
		});
	});

	describe("Carrier removal", function () {
		it("Should remove carrier role from other account", async function () {
			const { owner, otherAccount, role } = await loadFixture(deploy);
			await role.addCarrier(otherAccount.address);
			expect(await role.removeCarrier(otherAccount.address)).to.emit(
				role,
				"CarrierRemoved"
			);
		});
	});

	describe("Renounce carrier", function () {
		it("Should remove carrier role from other account", async function () {
			const { owner, otherAccount, role } = await loadFixture(deploy);
			await role.addCarrier(otherAccount.address);
			expect(
				await otherAccount.call(role.renounceCarrier(otherAccount.address))
			).to.emit(role, "CarrierRemoved");
		});
	});

	describe("Renounce member", function () {
		it("Should remove member role from other account", async function () {
			const { owner, otherAccount, role } = await loadFixture(deploy);
			await role.addMember(otherAccount.address);
			expect(
				await otherAccount.call(role.renounceMember(otherAccount.address))
			).to.emit(role, "MemberRemoved");
		});
	});

	// describe("Deployment", function () {
	// 	it("Should set the right entrance fee", async function () {
	// 		const { lottery } = await loadFixture(deploy);
	// 		expect(await lottery.enter()).to.be.reverted();
	// 	});

	// it("Should set the right owner", async function () {
	//   const { lock, owner } = await loadFixture(deployOneYearLockFixture);

	//   expect(await lock.owner()).to.equal(owner.address);
	// });

	// it("Should receive and store the funds to lock", async function () {
	//   const { lock, lockedAmount } = await loadFixture(
	//     deployOneYearLockFixture
	//   );

	//   expect(await hre.ethers.provider.getBalance(lock.address)).to.equal(
	//     lockedAmount
	//   );
	// });

	// it("Should fail if the unlockTime is not in the future", async function () {
	//   // We don't use the fixture here because we want a different deployment
	//   const latestTime = await time.latest();
	//   const Lock = await hre.ethers.getContractFactory("Lock");
	//   await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
	//     "Unlock time should be in the future"
	//   );
	// });
	// });

	// describe("Withdrawals", function () {
	//   describe("Validations", function () {
	//     it("Should revert with the right error if called too soon", async function () {
	//       const { lock } = await loadFixture(deployOneYearLockFixture);

	//       await expect(lock.withdraw()).to.be.revertedWith(
	//         "You can't withdraw yet"
	//       );
	//     });

	//     it("Should revert with the right error if called from another account", async function () {
	//       const { lock, unlockTime, otherAccount } = await loadFixture(
	//         deployOneYearLockFixture
	//       );

	//       // We can increase the time in Hardhat Network
	//       await time.increaseTo(unlockTime);

	//       // We use lock.connect() to send a transaction from another account
	//       await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
	//         "You aren't the owner"
	//       );
	//     });

	//     it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
	//       const { lock, unlockTime } = await loadFixture(
	//         deployOneYearLockFixture
	//       );

	//       // Transactions are sent using the first signer by default
	//       await time.increaseTo(unlockTime);

	//       await expect(lock.withdraw()).not.to.be.reverted;
	//     });
	//   });

	//   describe("Events", function () {
	//     it("Should emit an event on withdrawals", async function () {
	//       const { lock, unlockTime, lockedAmount } = await loadFixture(
	//         deployOneYearLockFixture
	//       );

	//       await time.increaseTo(unlockTime);

	//       await expect(lock.withdraw())
	//         .to.emit(lock, "Withdrawal")
	//         .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
	//     });
	//   });

	//   describe("Transfers", function () {
	//     it("Should transfer the funds to the owner", async function () {
	//       const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
	//         deployOneYearLockFixture
	//       );

	//       await time.increaseTo(unlockTime);

	//       await expect(lock.withdraw()).to.changeEtherBalances(
	//         [owner, lock],
	//         [lockedAmount, -lockedAmount]
	//       );
	//     });
	// });
	// });
});
