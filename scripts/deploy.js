const hre = require("hardhat");

async function main() {
  const CommitmentContract = await hre.ethers.getContractFactory("CommitmentContract");
  const contract = await CommitmentContract.deploy();

  await contract.deployed();
  console.log(`..CommitmentContract deployed at: ${contract.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
