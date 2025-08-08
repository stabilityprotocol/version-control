pragma solidity ^0.8.0;

contract CommitRegistry {
    
    struct CommitRecord {
        string codebaseHash;
        string author;
        string message;
        uint256 timestamp;
        address submitter;
        bool exists;
    }
    
    mapping(string => CommitRecord) public commits;
    string[] public commitHashes;
    
    event CommitStored(
        string indexed commitHash,
        string codebaseHash,
        string author,
        address indexed submitter,
        uint256 timestamp
    );
    
    function storeCommit(
        string memory commitHash,
        string memory codebaseHash,
        string memory author,
        string memory authorEmail,
        string memory branch,
        string memory message,
        string memory projectName
    ) external {
        require(bytes(commitHash).length > 0, "Commit hash required");
        require(!commits[commitHash].exists, "Commit exists");
        
        commits[commitHash] = CommitRecord({
            codebaseHash: codebaseHash,
            author: author,
            message: message,
            timestamp: block.timestamp,
            submitter: msg.sender,
            exists: true
        });
        
        commitHashes.push(commitHash);
        
        emit CommitStored(
            commitHash,
            codebaseHash,
            author,
            msg.sender,
            block.timestamp
        );
    }
    
    function getCommit(string memory commitHash) 
        external 
        view 
        returns (
            string memory codebaseHash,
            string memory author,
            string memory message,
            uint256 timestamp,
            address submitter
        ) 
    {
        require(commits[commitHash].exists, "Commit not found");
        
        CommitRecord memory record = commits[commitHash];
        return (
            record.codebaseHash,
            record.author,
            record.message,
            record.timestamp,
            record.submitter
        );
    }
    
    function getTotalCommits() external view returns (uint256) {
        return commitHashes.length;
    }
    
    function commitExists(string memory commitHash) external view returns (bool) {
        return commits[commitHash].exists;
    }
}