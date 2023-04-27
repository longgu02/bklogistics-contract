// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "node_modules/@openzeppelin/contracts/access/AccessControl.sol";

contract Roles is AccessControl {
    bytes32 public constant SUPPLIER_ROLE = keccak256("SUPPLIER");
    bytes32 public constant MANUFACTURER_ROLE = keccak256("MANUFACTURER");
    bytes32 public constant CUSTOMER_ROLE = keccak256("CUSTOMER");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    constructor(){
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(SUPPLIER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MANUFACTURER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(CUSTOMER_ROLE, ADMIN_ROLE);
    }
}