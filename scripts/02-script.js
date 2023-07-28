const { ethers } = require("hardhat");
const title = "I love food";
const description =
  "I food. Please donate Thanks ser";
const target = "5000000000000000000";
const deadline = "200123486328";
const image = "http://localhost:5173/src/assets/food.jpg";
const main = async () => {
  const crowdFunding = await ethers.getContract("CrowdFunding");
  console.log(crowdFunding.address);

  for (let I = 0; I < 25; I++) {
    console.log(`Creating: ${I + 1}`);
    const tx = await crowdFunding.createCampaign(
      title,
      description,
      target,
      deadline,
      image
    );
  }


  console.log("Campaign Created");
};
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
