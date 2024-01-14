// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @title VotingSystem
 * @dev This contract manages a decentralized voting system
 */
contract VotingSystem {
 /**
  * @dev Structure representing a Candidate
  */
 struct Candidate {
     // Name of the candidate
     string name;
     // Number of votes received by the candidate
     uint voteCount;
 }
 
 /**
  * @dev Structure representing a Voter
  */
 struct Voter {
     // Boolean indicating if the voter has voted
     bool hasVoted;
 }

 // Address of the contract owner
 address public owner;
 // Mapping of voter addresses to Voter instances
 mapping(address => Voter) public voters;
 // Mapping of candidate names to Candidate instances
 mapping(string => Candidate) public candidates;
 // Array of candidate names
 string[] public candidateNames;

 /**
  * @dev Constructor function that sets the contract owner
  */
 constructor() {
     owner = msg.sender;
 }

 /**
  * @dev Function to register a voter
  * @param voterAddress The address of the voter to register
  */
 function registerVoter(address voterAddress) public {
     // Only the contract owner can register voters
     require(msg.sender == owner, "Only the owner can register voters.");
     // Add the voter to the mapping
     voters[voterAddress] = Voter(false);
 }

 /**
  * @dev Function to add a candidate
  * @param name The name of the candidate to add
  */
 function addCandidate(string memory name) public {
     // Only the contract owner can add candidates
     require(msg.sender == owner, "Only the owner can add candidates.");
     // Add the candidate to the mapping
     candidates[name] = Candidate(name, 0);
     // Add the candidate name to the array
     candidateNames.push(name);
 }

 /**
  * @dev Function to cast a vote
  * @param candidateName The name of the candidate to vote for
  */
 function vote(string memory candidateName) public {
     // Check that the voter hasn't already voted
     require(!voters[msg.sender].hasVoted, "Each voter can only vote once.");
     // Check that the candidate exists
     require(candidates[candidateName].voteCount >= 0, "This candidate does not exist.");
     // Increment the candidate's vote count
     candidates[candidateName].voteCount += 1;
     // Mark the voter as having voted
     voters[msg.sender].hasVoted = true;
 }

 /**
  * @dev Function to get the results of the election
  * @return names An array of the names of all candidates
  * @return counts An array of the vote counts of all candidates
  */
 function getResults() public view returns (string[] memory names, uint[] memory counts) {
     // Initialize arrays to hold the names and vote counts
     names = new string[](candidateNames.length);
     counts = new uint[](candidateNames.length);
     // Iterate over the candidate names
     for (uint i = 0; i < candidateNames.length; i++) {
         // Get the name and vote count of each candidate
         names[i] = candidates[candidateNames[i]].name;
         counts[i] = candidates[candidateNames[i]].voteCount;
     }
 }
}
