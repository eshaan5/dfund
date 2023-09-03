// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target; // target to achieve
        uint256 deadline; // deadline to achieve target
        uint256 amountCollected; // amount raised
        string image;
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaigns; // array of campaigns
    uint256 public campaignsCount; // number of campaigns

    // memory is used to store temporary data - in memory area of EVM
    function createCampaign(address _owner, string memory _title, string memory _description, uint256 _target, uint256 _deadline, string memory _image) public returns (uint256) {
        Campaign storage campaign = campaigns[campaignsCount];

        // to check if everuthing is ok
        require(campaign.deadline >= block.timestamp);

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.image = _image;
        campaign.amountCollected = 0;

        campaignsCount++;

        return campaignsCount - 1;
    }

    // payable means that this function can receive ether
    function donate(uint256 _id) public payable {

        uint256 amount = msg.value; // from frontend

        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        (bool sent, ) = payable(campaign.owner).call{value: amount}("");

        if(sent) {
            campaign.amountCollected += amount;
        } else {
            revert("Failed to send Ether");
        }

    }

    function getDonators(uint256 _id) view public returns (address[] memory, uint256[] memory) {

        return (campaigns[_id].donators, campaigns[_id].donations);

    }

    function getCampaigns() public view returns (Campaign[] memory) {

        Campaign[] memory allCampaigns = new Campaign[](campaignsCount); // just an empty array at start

        for (uint256 i = 0; i < campaignsCount; i++) {

            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;

        }

        return allCampaigns;

    }
}