// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Insurance {
    struct Policy {
        address policyholder;
        uint256 premium;
        uint256 payout;
        uint256 startDate;
        uint256 endDate;
        bool claimed;
    }

    uint256 public policyCount;
    mapping(uint256 => Policy) public policies;

    event PolicyCreated(uint256 policyId, address policyholder, uint256 premium, uint256 payout, uint256 startDate, uint256 endDate);
    event PolicyClaimed(uint256 policyId, uint256 payout);

    function createPolicy(uint256 premium, uint256 payout, uint256 duration) external payable {
        require(msg.value == premium, "Incorrect premium amount");

        policyCount++;
        policies[policyCount] = Policy(
            msg.sender,
            premium,
            payout,
            block.timestamp,
            block.timestamp + duration,
            false
        );

        emit PolicyCreated(policyCount, msg.sender, premium, payout, block.timestamp, block.timestamp + duration);
    }

    function claimPolicy(uint256 policyId) external {
        Policy storage policy = policies[policyId];
        require(policy.policyholder == msg.sender, "Not the policyholder");
        require(block.timestamp >= policy.endDate, "Policy not matured");
        require(!policy.claimed, "Policy already claimed");

        policy.claimed = true;
        payable(policy.policyholder).transfer(policy.payout);

        emit PolicyClaimed(policyId, policy.payout);
    }

    function getPolicy(uint256 policyId) external view returns (address policyholder, uint256 premium, uint256 payout, uint256 startDate, uint256 endDate, bool claimed) {
        Policy storage policy = policies[policyId];
        return (policy.policyholder, policy.premium, policy.payout, policy.startDate, policy.endDate, policy.claimed);
    }
}
