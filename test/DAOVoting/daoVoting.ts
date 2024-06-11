import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers, network } from "hardhat";

import type { Signers } from "../types";
import { deployLockFixture } from "./daoVoting.fixture";

describe("DAO Voting", function () {
    before(async function () {
      this.signers = {} as Signers;
  
      const signers = await ethers.getSigners();
      this.signers.admin = signers[0];
  
      this.loadFixture = loadFixture;
    });

    describe("DAO", function () {
        beforeEach(async function () {
            const {
                dao,
            dao_address,
            owner,
            address1,
            address2,
            address3,
            address4
            } = await this.loadFixture(deployLockFixture);
    
            this.dao = dao;
            this.dao_address = dao_address;
            this.owner = owner;
            this.address1 = address1;
            this.address2 = address2;
            this.address3 = address3;
            this.address4 = address4;
        });
    
        it("initializeDAO", async function () {
            expect(await this.dao.connect(this.owner).initializeDAO(100,100,50)).not.to.be.reverted;
        });

        it("contribution", async function() {
            await this.dao.connect(this.owner).initializeDAO(100,100,50);
            await this.dao.connect(this.address1).contribution({value: 50});
            await this.dao.connect(this.address2).contribution({value: 50});
            await this.dao.connect(this.address3).contribution({value: 50});

            const test = await this.dao.connect(this.owner).allInvestorList();
            expect(test.length).equals(3);
        });

        it("contribution time check", async function() {
            await this.dao.connect(this.owner).initializeDAO(100,100,50);


            await this.dao.connect(this.address1).contribution({value: 50});

            await network.provider.send("evm_increaseTime", [33]);
            await network.provider.send("evm_mine");

            await this.dao.connect(this.address2).contribution({value: 50});

            await network.provider.send("evm_increaseTime", [33]);
            await network.provider.send("evm_mine");

            await this.dao.connect(this.address3).contribution({value: 50});

            await network.provider.send("evm_increaseTime", [23]);
            await network.provider.send("evm_mine");

            expect(await this.dao.connect(this.address4).contribution({value: 50})).to.be.reverted;
        });

        it("redeem Share", async function () {
            await this.dao.connect(this.owner).initializeDAO(100,100,50);


            await this.dao.connect(this.address1).contribution({value: 50});

            await network.provider.send("evm_increaseTime", [33]);
            await network.provider.send("evm_mine");

            await this.dao.connect(this.address2).contribution({value: 50});

            await network.provider.send("evm_increaseTime", [33]);
            await network.provider.send("evm_mine");

            await this.dao.connect(this.address3).contribution({value: 50});

            await network.provider.send("evm_increaseTime", [23]);
            await network.provider.send("evm_mine");

            const balanceBefore = await ethers.provider.getBalance(this.dao_address);

            await this.dao.connect(this.address1).redeemShare(50);

            const balanceAfter = await ethers.provider.getBalance(this.dao_address);

            expect(balanceBefore).be.greaterThan(balanceAfter);
        });

        it("transferShare", async function () {
            await this.dao.connect(this.owner).initializeDAO(100,100,50);


            await this.dao.connect(this.address1).contribution({value: 50});

            await network.provider.send("evm_increaseTime", [33]);
            await network.provider.send("evm_mine");

            await this.dao.connect(this.address2).contribution({value: 50});

            await network.provider.send("evm_increaseTime", [33]);
            await network.provider.send("evm_mine");

            await this.dao.connect(this.address3).contribution({value: 50});

            await network.provider.send("evm_increaseTime", [10]);
            await network.provider.send("evm_mine");

            await this.dao.connect(this.address1).transferShare(25, this.address4.address);

            const resp = await this.dao.connect(this.owner).allInvestorList();
            expect(resp.length).equals(4);
        });

        it("create Proposal", async function () {
            await this.dao.connect(this.owner).initializeDAO(100,100,60);


            await this.dao.connect(this.address1).contribution({value: 50});

            await network.provider.send("evm_increaseTime", [30]);
            await network.provider.send("evm_mine");

            await this.dao.connect(this.address2).contribution({value: 50});

            await network.provider.send("evm_increaseTime", [30]);
            await network.provider.send("evm_mine");

            await this.dao.connect(this.address3).contribution({value: 50});

            await network.provider.send("evm_increaseTime", [30]);
            await network.provider.send("evm_mine");

            await this.dao.connect(this.owner).createProposal("check", 30, this.address4.address);

            const proposal = await this.dao.connect(this.owner).proposalList();

           expect(proposal[0].length).equals(1);
        })
    });

});

