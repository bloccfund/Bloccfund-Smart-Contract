const networkConfig = {
  5001: {
    name: "mantle",
  },
  31337: {
    name: "hardhat",
  },
  1337: {
    name: "ganache",
  },
};

const developmentChains = ["localhost", "hardhat", "ganache"]

module.exports = {
  networkConfig,
  developmentChains,
  FRONTEND_ADDRESSES_FILE,
  FRONTEND_ABI_FILE
};
