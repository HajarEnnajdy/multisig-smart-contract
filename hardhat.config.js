require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.13",
  networks: {
    // This tells Hardhat to use your local Ganache blockchain
    ganache: {
      url: "http://127.0.0.1:7545",  // Ganache default RPC address
      chainId: 1337,                  // Ganache default chain ID
    },
  },
};
