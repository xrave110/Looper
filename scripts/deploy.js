const hre = require("hardhat");

async function deployLooper() {
  const Looper = await hre.ethers.getContractFactory("Looper");
  const looper = await Looper.deploy();
  await looper.deployed();
  return looper;
}

async function main() {
  const accounts = await hre.ethers.getSigners();
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;
  const lockedAmount = hre.ethers.utils.parseEther("1");

  const Looper = await hre.ethers.getContractFactory("Looper");
  const looper = await Looper.deploy();
  await looper.deployed();

  // const Lock = await hre.ethers.getContractFactory("Lock");
  // const lock = await Lock.deploy(unlockTime);
  // await lock.deployed();



  console.log(
    `Looper with ${ethers.utils.formatEther(
      lockedAmount
    )} ETH deployed to ${looper.address}`
  );
  // console.log("Swapping on looper")
  // tx = await looper.swapEth("0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb", 0, { value: lockedAmount });
  // let stEthBalance = await looper.getTokenBalance("0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb", looper.address)
  // console.log("Balance of staked Eth: %s", stEthBalance);

  console.log("Getting St ETH on looper");
  tx = await looper.getStEth({ value: lockedAmount });
  stEthBalance = await looper.getTokenBalance("0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb", looper.address)
  console.log("Balance of staked Eth: %s", ethers.utils.formatEther(stEthBalance.toString()));

  console.log("Depositing Staked %s Eth...", ethers.utils.formatEther(stEthBalance.toString()));
  tx = await looper.depositStEth(stEthBalance);
  let maiColateral = await looper.getMaiCollateral();
  stEthBalance = await looper.getTokenBalance("0x926B92B15385981416a5E0Dcb4f8b31733d598Cf", looper.address)
  console.log("Mai colateral: %s\nMoo eth: %s", ethers.utils.formatEther(maiColateral.toString()), ethers.utils.parseEther(stEthBalance.toString()));
  console.log(maiColateral);
  let maiToBorrow = maiColateral.div(2);
  console.log(maiToBorrow)
  console.log("Borrowing %s MAI ...", ethers.utils.formatEther(maiToBorrow.toString()));
  console.log("Account address: %s", accounts[0].address);
  await looper.borrowMai(maiToBorrow);
  let maiBorrowed = await looper.getTokenBalance("0xdFA46478F9e5EA86d57387849598dbFB2e964b02", looper.address);
  console.log("Borrowed %s MAI ...", maiBorrowed /*ethers.utils.formatEther(maiBorrowed.toString())*/);

  console.log(tx.data);
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

