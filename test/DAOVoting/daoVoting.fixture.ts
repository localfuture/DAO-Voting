import { time } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";

import type { DAO } from "../../types/DAO";
import type { DAO__factory } from "../../types/factories/DAO__factory";

export async function deployLockFixture() {
    const [owner, address1, address2, address3, address4] = await ethers.getSigners();

    const DAO = (await ethers.getContractFactory("DAO")) as DAO__factory;
    const dao = (await DAO.deploy()) as DAO;
    const dao_address = await dao.getAddress();

    return {
        dao,
        dao_address,
        owner,
        address1,
        address2,
        address3,
        address4
    };
}