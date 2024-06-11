// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DAO {
    function initializeDAO(
        uint256 _contributionTimeEnd,
        uint256 _voteTime,
        uint256 _quorum
    ) public {}


    function contribution() public payable {}

    function reedemShare(uint256 amount) public{}

    function transferShare(uint256 amount, address to) public {}

    function createProposal(string calldata description,uint256 amount,address payable receipient) public {}

    function voteProposal(uint256 proposalId) public {}

    function executeProposal(uint256 proposalId) public {}

    function proposalList() public returns (string[] ,uint[],address[]) {}

    function allInvestorList() public view returns (address[]) {}
}