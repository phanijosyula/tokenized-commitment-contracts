const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CommitmentContract", function () {
  let Commitment, commitment, Token, token, owner, user, validator;

  beforeEach(async () => {
    [owner, user, validator] = await ethers.getSigners();

    Token = await ethers.getContractFactory("TestToken");
    token = await Token.deploy();
    await token.deployed();

    Commitment = await ethers.getContractFactory("CommitmentContract");
    commitment = await Commitment.deploy();
    await commitment.deployed();

    // Mint and approve tokens
    await token.mint(user.address, ethers.utils.parseEther("100"));
    await token.connect(user).approve(commitment.address, ethers.utils.parseEther("10"));
  });

  it("should allow a user to create a commitment", async function () {
    await commitment.connect(user).createCommitment(
      token.address,
      ethers.utils.parseEther("10"),
      Math.floor(Date.now() / 1000) + 3600,
      "Finish test case",
      validator.address,
      false
    );
    const c = await commitment.commitments(0);
    expect(c.committer).to.equal(user.address);
  });

  it("should allow proof submission and validation", async function () {
    await commitment.connect(user).createCommitment(
      token.address,
      ethers.utils.parseEther("10"),
      Math.floor(Date.now() / 1000) + 3600,
      "Finish test case",
      validator.address,
      false
    );
    await commitment.connect(user).submitProof(0, "ipfs://proof");
    await commitment.connect(validator).validateCommitment(0, true);
    const c = await commitment.commitments(0);
    expect(c.validated).to.be.true;
    expect(c.success).to.be.true;
  });

  it("should allow successful claim", async function () {
    await commitment.connect(user).createCommitment(
      token.address,
      ethers.utils.parseEther("10"),
      Math.floor(Date.now() / 1000) + 3600,
      "Finish test case",
      validator.address,
      false
    );
    await commitment.connect(user).submitProof(0, "ipfs://proof");
    await commitment.connect(validator).validateCommitment(0, true);
    await commitment.connect(user).claim(0);
    const userBalance = await token.balanceOf(user.address);
    expect(userBalance).to.equal(ethers.utils.parseEther("100"));
  });
});
