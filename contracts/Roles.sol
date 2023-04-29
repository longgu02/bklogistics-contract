// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// This contract defines roles for a supply chain management system.
// It inherits from the OpenZeppelin AccessControl contract and uses its functions
// to manage roles.

import "node_modules/@openzeppelin/contracts/access/AccessControl.sol";

contract Roles is AccessControl {
    // Define the role IDs as constants for easier use
    bytes32 public constant SUPPLIER_ROLE = keccak256("SUPPLIER");
    bytes32 public constant MANUFACTURER_ROLE = keccak256("MANUFACTURER");
    bytes32 public constant CUSTOMER_ROLE = keccak256("CUSTOMER");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    constructor(){
        // The deployer of the contract is given the admin role
        _setupRole(ADMIN_ROLE, msg.sender);
        // The admin role is set as the role admin for each of the other roles
        _setRoleAdmin(SUPPLIER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MANUFACTURER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(CUSTOMER_ROLE, ADMIN_ROLE);
    }
}