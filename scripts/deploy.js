/**
 * deploy.js
 * =========
 * This script deploys the MultiSigWallet contract to Ganache.
 * Run it with: npm run deploy
 *
 * It will:
 *  1. Connect to Ganache
 *  2. Read the first 3 accounts from Ganache as owners
 *  3. Deploy the contract with those owners and threshold = 2
 *  4. Print the contract address and owner addresses
 *     → Copy these into the frontend interface!
 */

const { ethers } = require("hardhat");

async function main() {
  // Get the list of accounts Ganache provides
  const accounts = await ethers.getSigners();

  // We use the first 3 accounts as owners of the wallet
  const owners = [
    accounts[0].address,
    accounts[1].address,
    accounts[2].address,
  ];

  // 2 out of 3 owners must approve before a transaction executes
  const required = 2;

  console.log("Deploying MultiSigWallet...");
  console.log("Owners:", owners);
  console.log("Required approvals:", required);

  // Get the contract factory (Hardhat compiles the .sol for us)
  const MultiSigWallet = await ethers.getContractFactory("MultiSigWallet");

  // Deploy the contract — this sends a transaction to Ganache
  const wallet = await MultiSigWallet.deploy(owners, required);

  // Wait until the deployment transaction is confirmed
  await wallet.waitForDeployment();

  const contractAddress = await wallet.getAddress();

  console.log("\n✅ Contract deployed successfully!");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("Contract address :", contractAddress);
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("Owner 0 (account 0):", owners[0]);
  console.log("Owner 1 (account 1):", owners[1]);
  console.log("Owner 2 (account 2):", owners[2]);
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("\n👉 Copy the contract address and owner addresses");
  console.log("   into the CONFIG section at the top of frontend/index.html");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
