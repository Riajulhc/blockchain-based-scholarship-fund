// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScholarshipFund {
    address public owner;
    uint256 public totalFunds;
    uint256 public scholarshipAmount;
    bool public fundDisbursed;

    struct Contributor {
        uint256 amount;
        bool hasWithdrawn;
    }

    mapping(address => Contributor) public contributors;
    address[] public contributorList;

    event ContributionReceived(address contributor, uint256 amount);
    event ScholarshipDisbursed(address recipient, uint256 amount);

    constructor(uint256 _scholarshipAmount) {
        owner = msg.sender;
        scholarshipAmount = _scholarshipAmount;
        fundDisbursed = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier hasNotDisbursed() {
        require(!fundDisbursed, "Funds have already been disbursed");
        _;
    }

    // Function for contributors to donate
    function contribute() public payable hasNotDisbursed {
        require(msg.value > 0, "Contribution must be greater than zero");
        
        Contributor storage contributor = contributors[msg.sender];
        if (contributor.amount == 0) {
            contributorList.push(msg.sender);
        }
        
        contributor.amount += msg.value;
        totalFunds += msg.value;
        
        emit ContributionReceived(msg.sender, msg.value);
    }

    // Function to distribute scholarships
    function distributeScholarship(address recipient) public onlyOwner hasNotDisbursed {
        require(totalFunds >= scholarshipAmount, "Insufficient funds for scholarship");
        require(recipient != address(0), "Invalid recipient address");

        fundDisbursed = true;
        payable(recipient).transfer(scholarshipAmount);

        emit ScholarshipDisbursed(recipient, scholarshipAmount);
    }

    // Function to withdraw funds (for the owner)
    function withdraw() public onlyOwner {
        require(fundDisbursed, "Funds have not been disbursed yet");
        
        uint256 remainingFunds = address(this).balance;
        require(remainingFunds > 0, "No funds available to withdraw");

        payable(owner).transfer(remainingFunds);
    }

    // Function to get the list of contributors
    function getContributors() public view returns (address[] memory) {
        return contributorList;
    }

    // Function to get the contribution amount of a specific contributor
    function getContribution(address contributorAddress) public view returns (uint256) {
        return contributors[contributorAddress].amount;
    }
}
