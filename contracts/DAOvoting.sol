// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.20;

contract DAO {
    address owner;
    uint256 contributionTimeEnd;
    uint256 voteTime; 
    uint256 quorum;

    mapping(address => uint) balanceOfUsers;

    struct Proposal {
        string description;
        uint amount;
        address payable receipient;
        uint totalVotes;
        mapping(address => bool) isVoted;
    }
    
    uint pId;
    mapping(uint => Proposal)proposals;

    uint uId;
    mapping(uint => address)users;
    mapping(address => bool)isUser;

    constructor() {
        owner = msg.sender;
    }

    // @dev Initializes the DAO with specific parameters.
    // @params _contributionTimeEnd sets the duration, 
    // in seconds from the initialization of the DAO, 
    // during which contributions are accepted.
    // @params _voteTime this parameter sets the duration, 
    // measured in seconds from the creation of a proposal, 
    // during which voting is open.
    // @params _quorum represents the minimum percentage of 
    // the combined total vote weightage from all contributors 
    // required for a proposal to be executed. Each vote holds 
    // a weight equivalent to the number of shares held by the individual voter.
    function initializeDAO(uint256 _contributionTimeEnd, uint256 _voteTime, uint256 _quorum) public {
        require(msg.sender == owner, "Only User");
        require(_contributionTimeEnd > 0, "time");
        require(_voteTime > 0, "vote");
        require(_quorum > 0, "quorum");
        
        contributionTimeEnd = block.timestamp + _contributionTimeEnd;
        voteTime = block.timestamp + _voteTime + contributionTimeEnd;
        quorum = _quorum;
    }

    // @Allows users to contribute ETH to the DAO.
    // The amount contributed is converted into shares and added to the user's balance.
    // The function ensures that contributions are only accepted within the set contribution time frame 
    // and that the amount is greater than zero.
    function contribution() public payable {
        require(msg.sender != owner, "Only User");
        require(block.timestamp < contributionTimeEnd, "Over");
        require(msg.value > 0, "Insufficient");

        if (isUser[msg.sender] == false) {
            isUser[msg.sender] = true;
            users[uId] = msg.sender;
            uId++;
        }

        balanceOfUsers[msg.sender] += msg.value;
    }

    // @dev Enables investors to redeem their shares in exchange for the equivalent 
    // amount in Wei (1 wei equals 1 share) from the DAO's available funds.
    // The function checks if the investor has enough shares and if the DAO has sufficient 
    // available funds before proceeding with the redemption.
    function redeemShare(uint256 amount) public {
        require(isUser[msg.sender], "Only user");
        require(balanceOfUsers[msg.sender] >= amount, "Insufficient deposit");
        require(address(this).balance >= amount, "Insufficient balance in contract");

        balanceOfUsers[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    // @dev Allows investors to transfer a specified amount of their shares to another address.
    // The function ensures that the investor has enough shares to transfer and that the DAO has enough available funds.
    // The recipient is added to the list of investors if not already present.
    function transferShare(uint256 amount, address to) public {
        require(amount > 0, "Insufficient");
        require(balanceOfUsers[msg.sender] >= amount, "Insufficient deposit");
        require(address(this).balance >= amount, "Insufficient balance in contract");

        balanceOfUsers[msg.sender] -= amount;

        if (isUser[to] == false) {
            isUser[to] = true;
            users[uId] = to;
            uId++;
        }

        balanceOfUsers[to] += amount;
    }

    // @dev Used by the contract owner to create a new proposal for funding.
    // The proposal includes a description, the amount requested, the recipient's address.
    // The function checks if there are enough available funds before creating the proposal.
    function createProposal(string calldata description, uint256 amount, address payable receipient) public {
        require(owner == msg.sender, "only owner");
        require(address(this).balance >= amount, "Insufficient balance in contract");

        proposals[pId].description = description;
        proposals[pId].amount = amount;
        proposals[pId].receipient = receipient;
        pId++;
    }

    // @dev Allows investors to cast their votes on a specific proposal.
    // The function ensures that an investor can only vote once per proposal and that the voting period is still open.
    // Each vote holds a weight equivalent to the number of shares held by the individual voter.
    function voteProposal(uint256 proposalId) public {
        require(isUser[msg.sender] == true, "Only user");
        require(block.timestamp < voteTime, "voting closed");
        require(proposals[proposalId].isVoted[msg.sender] == false, "already voted");

        proposals[proposalId].totalVotes += balanceOfUsers[msg.sender];
        proposals[proposalId].isVoted[msg.sender] = true;
    }

    // @dev Can be called by the contract owner to execute a proposal after the voting period has ended.
    // The function checks if the proposal has received enough vote weightage to meet the quorum and then transfers the requested funds to the recipient if successful.
    function executeProposal(uint256 proposalId) public {
        require(owner == msg.sender, "Only owner");
        require(quorum <= proposals[proposalId].totalVotes, "Votes insufficient");
        require(address(this).balance >= proposals[proposalId].amount, "Insufficient balance in contract");

        proposals[proposalId].receipient.transfer(proposals[proposalId].amount);
    }

    // @dev Returns 3 arrays, array of all the description, 
    // array of amount, and array of recipient, where each 
    // index of these represents a proposal.
    function proposalList() public view returns (string[] memory, uint[] memory, address[] memory) {

        string[] memory descriptions = new string[](pId);
        uint[] memory amounts = new uint[](pId);
        address[] memory receipients = new address[](pId);

        for(uint i = 0; i < pId; i++) {
            descriptions[i] = proposals[i].description;
            amounts[i] = proposals[i].amount;
            receipients[i] = proposals[i].receipient;
        }

        return (descriptions, amounts, receipients);
    }

    // @dev Provides a list of all investor addresses that have contributed to the DAO. This function is useful for tracking and managing the investor base.
    function allInvestorList() public view returns (address[] memory) {
        require(uId > 0, "No investors");

        address[] memory investors = new address[](uId);

        for(uint i = 0; i < uId; i++) {
            investors[i] = users[i];
        }

        return investors;
    }
}
