require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("hardhat-deploy");

/** @type import('hardhat/config').HardhatUserConfig */

const MANTLE_RPC_URL = process.env.MANTLE_RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const GANACHE_PRIVATE_KEY = process.env.GANACHE_PRIVATE_KEY;

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    mantle: {
      url: MANTLE_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 5001,
      blockConfirmations: 6,
    },
    localhost: {
      url: "http://127.0.0.1:8545/",
      chainId: 31337,
      ens: {
        enabled: true,
      },
    },
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: [GANACHE_PRIVATE_KEY],
      chainId: 1337,
      blockConfirmations: 1,
      ens: {
        enabled: true,
      },
    },
  },
  solidity: {
    compilers: [{ version: "0.8.18" }, { version: "0.6.6" }],
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    player: {
      default: 1,
    },
  },
  mocha: {
    timeout: 500000,
  },
};
