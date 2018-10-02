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
    Set.Data pendingProposalIndicies;

    event ProposalRewardCreate(uint index, uint256 value);
    event ProposalRewardUpdate(uint index, uint256 value);
    event ProposalAccepted(uint index, uint256 value);

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

        pendingProposalIndicies.add(proposals.length);
        proposals.push(Proposal({
            text: _proposal,
            reward: msg.value
        }));
    }

    function voteForProposal(uint _proposalIndex) public payable {
        require(pendingProposalIndicies.contains(_proposalIndex), "Proposal do not exist");
        proposals[_proposalIndex].reward += msg.value;
    }

    function acceptProposal(uint _proposalIndex) public onlyOwner {
        require(pendingProposalIndicies.remove(_proposalIndex), "Proposal does not exist");
        msg.sender.transfer(proposals[_proposalIndex].reward);
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