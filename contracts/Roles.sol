// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// This contract defines roles for a supply chain management system.
// It inherits from the OpenZeppelin AccessControl contract and uses its functions
// to manage roles.

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Roles is AccessControl {
    // Define the role IDs as constants for easier use
    bytes32 public constant CARRIER_ROLE = keccak256("CARRIER_ROLE"); // For shipment
    bytes32 public constant MEMBER_ROLE = keccak256("MEMBER"); // For supply chain
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    constructor() {
        // The deployer of the contract is given the admin role
        _setupRole(ADMIN_ROLE, msg.sender);
        // The admin role is set as the role admin for each of the other roles
        _setRoleAdmin(MEMBER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(CARRIER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
    }

    event MemberAdded(address account, uint256 addedDate); // Member addition
    event MemberRemoved(address account, uint256 removedDate); // Member removal

    function addMember(address _account) public onlyRole(ADMIN_ROLE) {
        require(!hasRole(MEMBER_ROLE, _account), "Already a member");
        grantRole(MEMBER_ROLE, _account);
        emit MemberAdded(_account, block.timestamp);
    }

    function removeMember(address _account) public onlyRole(ADMIN_ROLE) {
        require(hasRole(MEMBER_ROLE, _account), "Not a member");
        revokeRole(MEMBER_ROLE, _account);
        emit MemberRemoved(_account, block.timestamp);
    }

    function renounce(address _account) public onlyRole(MEMBER_ROLE) {
        renounceRole(MEMBER_ROLE, _account);
        emit MemberRemoved(_account, block.timestamp);
    }

    /**
     * @dev Grants the CARRIER_ROLE to a specified account.
     * @param _account Address of the account to grant the CARRIER_ROLE to.
     * Can only be called by accounts with the ADMIN_ROLE.
     */

    function addCarrier(address _account) public onlyRole(ADMIN_ROLE) {
        grantRole(CARRIER_ROLE, _account);
    }

    /**
     * @dev Renounce the CARRIER_ROLE to a specified account.
     * @param _account Address of the account to renounce the CARRIER_ROLE to.
     * Can only be called by accounts with the CARRIER_ROLE.
     */
    function renounceCarrier(address _account) public onlyRole(CARRIER_ROLE) {
        renounceRole(CARRIER_ROLE, _account);
    }
}
