require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const SONGBIRD_RPC = process.env.SONGBIRD_RPC_URL || "https://songbird.towolabs.com/rpc";
const FLARE_RPC = process.env.FLARE_RPC_URL || "https://flare.towolabs.com/rpc";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "0x0000000000000000000000000000000000000000000000000000000000000000";

module.exports = {
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {
      chainId: 1337,
    },
    songbird: {
      url: SONGBIRD_RPC,
      accounts: [PRIVATE_KEY],
      chainId: 16,
      gasPrice: 25000000000, // 25 gwei
    },
    flare: {
      url: FLARE_RPC,
      accounts: [PRIVATE_KEY],
      chainId: 14,
      gasPrice: 25000000000, // 25 gwei
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: {
    timeout: 200000,
  },
};
