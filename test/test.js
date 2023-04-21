const main = async () => {
  const domainContractFactory = await hre.ethers.getContractFactory('Domains');
  const domainContract = await domainContractFactory.deploy("subport");
  await domainContract.deployed();

  console.log("Contract deployed to:", domainContract.address);

  // CHANGE THIS DOMAIN TO SOMETHING ELSE! I don't want to see OpenSea full of bananas lol
  let txn = await domainContract.register("deployer", 'creator', {value: hre.ethers.utils.parseEther('0.1')});
  await txn.wait();
  console.log("Minted domain deployer.subport");

  txn = await domainContract.setRecord("deployer", "The beginning");
  await txn.wait();
  console.log("Set record for deployer.subport");

  const address = await domainContract.getAddress("deployer");
  console.log("Owner of domain deployer:", address);

  const balance = await hre.ethers.provider.getBalance(domainContract.address);
  console.log("Contract balance:", hre.ethers.utils.formatEther(balance));
}

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
