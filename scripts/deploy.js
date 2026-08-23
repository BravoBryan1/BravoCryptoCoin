const hre = require("hardhat");

async function main() {
  console.log("🚀 Deploying BravoCryptoCoin...");
  
  const BravoCryptoCoin = await hre.ethers.getContractFactory("BravoCryptoCoin");
  const token = await BravoCryptoCoin.deploy();
  
  await token.deployed();
  
  console.log("✅ BravoCryptoCoin deployed to:", token.address);
  console.log("\n📊 Token Information:");
  console.log("   Name: BravoCryptoCoin");
  console.log("   Symbol: BBCC");
  console.log("   Total Supply: 77,000,000 tokens");
  console.log("   Starting Price: €5 per token");
  console.log("   Network:", hre.network.name);
  console.log("   Chain ID:", (await hre.ethers.provider.getNetwork()).chainId);
  
  // Get deployment info
  const totalSupply = await token.TOTAL_SUPPLY();
  const contractBalance = await token.balanceOf(token.address);
  const vaultBalance = await token.getVaultBalance();
  
  console.log("\n💰 Token Distribution:");
  console.log("   Total Supply:", hre.ethers.utils.formatEther(totalSupply), "BBCC");
  console.log("   Contract Balance:", hre.ethers.utils.formatEther(contractBalance), "BBCC");
  console.log("   Vault Balance (Phase 3):", hre.ethers.utils.formatEther(vaultBalance), "BBCC");
  
  console.log("\n📅 Phase Timeline:");
  console.log("   Phase 1: 14/09/2026 - 14/03/2027");
  console.log("   Phase 2: 02/04/2027 - 01/04/2032");
  console.log("   Phase 3 Unlock: 29/06/2045");
  
  console.log("\n⏳ Time until Phase 3 unlock:", await token.getTimeUntilPhase3(), "seconds");
  
  console.log("\n📝 Contract Address:", token.address);
  console.log("\n✨ BravoCryptoCoin: Where the brilliance of gold meets the speed of light.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
