// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error CrowdFunding__DeadlineShouldBeInTheFuture();
error CrowdFunding__DonationNotSuccessFully();
error CrowdFunding__PleaseSendEnough();
error CrowdFunding__NotOwner();
error CrowdFunding__DeadlinePassed();
error CrowdFunding__WithdrawInvestmentFailed();

contract CrowdFunding is ReentrancyGuard {
    struct Campaign {
        address owner;
        string title;
        string description;
        string deck;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        bool onMarketplace;
        address[] investors;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaigns;
    mapping(address => mapping (uint256 => uint256)) investorInvestmentinEachCampaign;

    uint256 public campaignId = 0;

    event CampaignCreated(
        address indexed _owner,
        string _title,
        string _description,
        uint256 _target,
        uint256 _deadline,
        string _image
    );

    modifier isOwner(address owner, uint256 _id) {
        Campaign storage campaign = campaigns[_id];
        if (campaign.owner != msg.sender) {
            revert CrowdFunding__NotOwner();
        }
        _;
    }
    modifier isDeadlinePassed(uint256 _id) {
        Campaign storage campaign = campaigns[_id];
        if (campaign.deadline < block.timestamp) {
            revert CrowdFunding__DeadlinePassed();
        }
        _;
    }
    modifier isAnInvestor(uint256 _id) {
        Campaign storage campaign = campaigns[_id];
        for (uint i = 0; i < campaign.investors.length; i++) {
            if (campaign.investors[i] == msg.sender) {
                _;
                break;
            }
        }
    }

    function createCampaign(
        string memory _title,
        string memory _description,
        string memory _deck,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    ) external nonReentrant {
        Campaign storage campaign = campaigns[campaignId];

        if (_deadline <= block.timestamp) {
            revert CrowdFunding__DeadlineShouldBeInTheFuture();
        }
        campaign.owner = msg.sender;
        campaign.title = _title;
        campaign.description = _description;
        campaign.deck = _deck;
        campaign.onMarketplace = true;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.image = _image;

        campaignId++;

        emit CampaignCreated(
            msg.sender,
            _title,
            _description,
            _target,
            _deadline,
            _image
        );
    }

    function donateToCampaign(
        uint256 _id
    ) external payable isDeadlinePassed(_id) {
        if (msg.value <= 0) {
            revert CrowdFunding__PleaseSendEnough();
        }
        uint256 amount = msg.value;
        address investor = msg.sender;
        investorInvestmentinEachCampaign[investor][_id] = amount;
        Campaign storage campaign = campaigns[_id];
        campaign.investors.push(msg.sender);
        campaign.donations.push(amount);
        campaign.amountCollected = campaign.amountCollected + amount;
    }

    function changeVisibility(
        uint256 _id
    ) external isOwner(msg.sender, _id) isDeadlinePassed(_id) {
        Campaign storage campaign = campaigns[_id];
        campaign.onMarketplace = !campaign.onMarketplace;
    }

    function withdrawInvestment(uint256 _id) external isDeadlinePassed(_id) isAnInvestor(_id) {
        Campaign storage campaign = campaigns[_id];
        uint256 amountInvested = investorInvestmentinEachCampaign[msg.sender][_id];
        campaign.amountCollected -= amountInvested;
        (bool success,) = payable(msg.sender).call{value: amountInvested}("");
        if(!success){
            revert CrowdFunding__WithdrawInvestmentFailed();
        }
    }




    function getInvestors(
        uint256 _id
    ) public view returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].investors, campaigns[_id].donations);
    }

    function getAllCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](campaignId);

        for (uint i = 0; i < campaignId; i++) {
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }
        return allCampaigns;
    }
}
