pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./lib/Set.sol";


contract Donatocracy is Ownable {
    using Set for Set.Data;

    uint256 public minReward = 10 finney;

    struct Proposal {
        string text;
        uint256 reward;
    }

    Proposal[] public proposals;
    Set.Data internal pendingProposalIndicies;

    event ProposalCreated(uint index, uint256 value);
    event ProposalVoted(uint index, uint256 value);
    event ProposalMerged(uint index, uint duplicateIndex);
    event ProposalAccepted(uint index, uint256 value);

    function proposalsCount() public view returns(uint) {
        return proposals.length;
    }

    function allProposals() public view returns(string concatenatedTexts, uint[] starts) {
        bytes memory result;
        starts = new uint[](proposals.length);
        for (uint i = 0; i < proposals.length; i++) {
            result = abi.encodePacked(result, proposals[i].text);
            starts[i] = result.length;
        }
        concatenatedTexts = string(result);
    }

    function allPendingProposalIndicies() public view returns(uint[]) {
        return pendingProposalIndicies.items;
    }

    function setMinReward(uint256 _minReward) public onlyOwner {
        minReward = _minReward;
    }

    function createProposal(string _proposal) public payable {
        require(msg.value >= minReward, "Proposal creation requires more value");

        emit ProposalCreated(proposals.length, msg.value);
        pendingProposalIndicies.add(proposals.length);
        proposals.push(Proposal({
            text: _proposal,
            reward: msg.value
        }));
    }

    function voteForProposal(uint _proposalIndex) public payable {
        require(pendingProposalIndicies.contains(_proposalIndex), "Proposal do not exist");
        proposals[_proposalIndex].reward += msg.value;
        emit ProposalVoted(_proposalIndex, msg.value);
    }

    function acceptProposal(uint _proposalIndex) public onlyOwner {
        require(pendingProposalIndicies.remove(_proposalIndex), "Proposal does not exist");
        msg.sender.transfer(proposals[_proposalIndex].reward);
    }

    function mergerProposal(uint _proposalIndex, uint _duplicateProposalIndex, string _newText) public onlyOwner {
        require(pendingProposalIndicies.contains(_proposalIndex), "Proposal does not exist");
        require(pendingProposalIndicies.remove(_duplicateProposalIndex), "Proposal does not exist");
        proposals[_proposalIndex].reward += proposals[_duplicateProposalIndex].reward;
        proposals[_duplicateProposalIndex].reward = 0;
        proposals[_proposalIndex].text = _newText;
        emit ProposalMerged(_proposalIndex, _duplicateProposalIndex);
    }

    function bestProposal() public view returns(uint bestProposalIndex, uint256 bestProposalReward) {
        for (uint i = 0; i < pendingProposalIndicies.length(); i++) {
            uint proposalIndex = pendingProposalIndicies.at(i);
            uint256 proposalReward = proposals[proposalIndex].reward;

            if (proposalReward > bestProposalReward) {
                bestProposalReward = proposalReward;
                bestProposalIndex = proposalIndex;
            }
        }
    }
}