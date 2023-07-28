const { ethers, network } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");
module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  log("--------------------------");
  const args = [];
  const crowdFunding = await deploy("CrowdFunding", {
    from: deployer,
    args: args,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  // if (
  //   !developmentChains.includes(network.name) &&
  //   process.env.ETHERSCAN_API_KEY
  // ) {
  //   log("verify.....");
  //   await verify(crowdFunding.address, args);
  // } else {
  //   log("On a develpoment-chain not verifing");
  // }
  log("--------------------------");
};

module.exports.tags = ["all", "crowdFunding"];
