
const { expect } = require("chai");
const { ethers } = require("hardhat");

// let provider = ethers.getDefaultProvider();
/**
 *@dev setup constants
 *
 * @dev setup signers using ethers
 *
 * @dev Deploys smart contract with ethers js
 */

describe("ERC20 Token Testing", async () => {
  let deployer: any;
  let owner:any;

  beforeEach("deploy Pawnshop contract", async () => {
    const [primary, secondary, delegate] = await ethers.getSigners();
    owner = primary;
    const PawnShop = await ethers.getContractFactory("PawnShop");
    deployer = await PawnShop.deploy(1000);
    await deployer.deployed();
    console.log(`PWN Token deployed at ${deployer.address}`);
  });

  it("Should Check if Total Token Supply is Equal to 1000", async function () {
    const totalSupply = await deployer.totalSupply();
    expect(totalSupply).to.equal(1000);
  });

  it("should have all tokens in my account", async () => {
      const totalSupply = await deployer.totalSupply();
      const deployerAccount  = await deployer.address;
  });

});
