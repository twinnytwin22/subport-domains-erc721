require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');
require('@nomiclabs/hardhat-etherscan')
require('dotenv').config();

module.exports = {
  solidity: '0.8.10',
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.POLYGONSCAN_API
    },
  },
  networks: {
    mumbai: {
     
      url: process.env.STAGING_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    },
    matic: {
      chainId: 137,
      url: process.env.PROD_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    },
    mainnet: {
      chainId: 1,
      url: process.env.PROD_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};