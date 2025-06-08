// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract CommitmentContract {
    struct Commitment {
        address committer;
        address token;
        uint256 amount;
        uint256 deadline;
        string description;
        string proofURI;
        bool validated;
        bool claimed;
        bool success;
        address validator;
        bool mintNFT;
    }

    Commitment[] public commitments;

    event CommitmentCreated(uint256 id, address indexed user, string description, uint256 deadline);
    event ProofSubmitted(uint256 id, string uri);
    event CommitmentValidated(uint256 id, bool success);
    event Claimed(uint256 id, bool refunded);
    event Slashed(uint256 id);

    function createCommitment(
        address token,
        uint256 amount,
        uint256 deadline,
        string calldata description,
        address validator,
        bool mintNFT
    ) external {
        require(deadline > block.timestamp, "Deadline must be in future");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        commitments.push(Commitment({
            committer: msg.sender,
            token: token,
            amount: amount,
            deadline: deadline,
            description: description,
            proofURI: "",
            validated: false,
            claimed: false,
            success: false,
            validator: validator,
            mintNFT: mintNFT
        }));
        emit CommitmentCreated(commitments.length - 1, msg.sender, description, deadline);
    }

    function submitProof(uint256 id, string calldata proofURI) external {
        Commitment storage c = commitments[id];
        require(msg.sender == c.committer, "Only committer");
        require(block.timestamp <= c.deadline, "Past deadline");
        c.proofURI = proofURI;
        emit ProofSubmitted(id, proofURI);
    }

    function validateCommitment(uint256 id, bool success) external {
        Commitment storage c = commitments[id];
        require(msg.sender == c.validator, "Only validator");
        require(bytes(c.proofURI).length > 0, "No proof submitted");
        c.validated = true;
        c.success = success;
        emit CommitmentValidated(id, success);
    }

    function claim(uint256 id) external {
        Commitment storage c = commitments[id];
        require(msg.sender == c.committer, "Only committer");
        require(c.validated, "Not validated");
        require(!c.claimed, "Already claimed");
        c.claimed = true;
        if (c.success) {
            IERC20(c.token).transfer(c.committer, c.amount);
            emit Claimed(id, true);
        } else {
            emit Claimed(id, false);
        }
    }

    function slashExpired(uint256 id) external {
        Commitment storage c = commitments[id];
        require(block.timestamp > c.deadline, "Not expired");
        require(!c.validated && !c.claimed, "Already handled");
        c.claimed = true;
        emit Slashed(id);
        // Tokens could be burned or sent to DAO treasury here
    }
}
