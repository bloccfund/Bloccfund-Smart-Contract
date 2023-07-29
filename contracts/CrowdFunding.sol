// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error CrowdFunding__DeadlineShouldBeInTheFuture();
error CrowdFunding__DonationNotSuccessFully();
error CrowdFunding__PleaseSendEnough();
error CrowdFunding__NotOwner();
error CrowdFunding__DeadlinePassed();
error CrowdFunding__Withdrawal();
error CrowdFunding__YouCannotWithdrawYet();
error CrowdFunding__CampaignDoesNotExist();

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

    event CampaignCreated(
        address indexed _owner,
        string _title,
        string _description,
        uint256 _target,
        uint256 _deadline,
        string _image
    );

    /////////////
    // Mapping //
    /////////////

    mapping(uint256 => Campaign) public campaigns;
    mapping(address => mapping(uint256 => uint256)) investorInvestmentinEachCampaign;

    uint256 public campaignId = 0;

    ///////////////
    // Modifiers //
    ///////////////

    /**
     * @param _id: Campaign ID
     */

    modifier isOwner(uint256 _id) {
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
    modifier doesCampaignExist(uint256 _id){
        Campaign storage campaign = campaigns[_id];
        if(campaign.deadline == 0){
            revert CrowdFunding__CampaignDoesNotExist();
        }
        _;
    }

    ////////////////////
    // Main Functions //
    ////////////////////

    /**
     * @notice Function for creating a new Campaign
     * @param _title: Campaign Title
     * @param _description: Campaign Description
     * @param _deck: Campaign Pitch Deck
     * @param _target: Campaign Target
     * @param _deadline: Campaign Deadline
     * @param _image: Campaign Image
     */

    function createCampaign(
        string memory _title,
        string memory _description,
        string memory _deck,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    ) external {
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

    /**
     * @param _id: Campaign ID
     */

    function donateToCampaign(
        uint256 _id
    ) external payable isDeadlinePassed(_id) doesCampaignExist(_id) {
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

    /**
     * @param _id: Campaign ID
     */

    function changeVisibility(
        uint256 _id
    ) external isOwner(_id) isDeadlinePassed(_id) doesCampaignExist(_id) {
        Campaign storage campaign = campaigns[_id];
        campaign.onMarketplace = !campaign.onMarketplace;
    }

    /**
     * @notice The Function is for investors who wants to withdraw their
     * investment away from a campaign they are no longer interested in
     * @param _id: Campaign ID
     */

    function withdrawInvestment(
        uint256 _id
    ) external nonReentrant isDeadlinePassed(_id) isAnInvestor(_id) doesCampaignExist(_id) {
        Campaign storage campaign = campaigns[_id];
        uint256 amountInvested = investorInvestmentinEachCampaign[msg.sender][
            _id
        ];
        campaign.amountCollected -= amountInvested;
        (bool success, ) = payable(msg.sender).call{value: amountInvested}("");
        if (!success) {
            revert CrowdFunding__Withdrawal();
        }
    }

    /**
     * @notice This Function is for campaign owners to withdraw the funds they have raised
     * @notice Withdrawal can not be placed if campaign is not over
     * @param _id: Campaign ID
     */

    function withdrawCampaignFunds(uint256 _id) external nonReentrant isOwner(_id) doesCampaignExist(_id) {
        Campaign storage campaign = campaigns[_id];
        uint256 amount = campaign.amountCollected;
        if (campaign.deadline > block.timestamp) {
            revert CrowdFunding__YouCannotWithdrawYet();
        } else {
            (bool success, ) = payable(msg.sender).call{value: amount}("");
            if (!success) {
                revert CrowdFunding__Withdrawal();
            }
        }
    }

    //////////////////////
    // Getter Functions //
    //////////////////////

    function getAllInvestors(
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

// check if camapign exist
// return all the campaign an investor have invested in
