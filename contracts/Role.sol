// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Roles {
    /**
     * Included 3 Roles:
     * - Supplier
     * - Manufacturer
     * - Contributor or Retailer (as Customer)
     */
    enum RoleType {
        NONE, // default
        SUPPILER,
        MANUFACTURER,
        CUSTOMER
    }
    address[] members; // Members list for counting
    mapping(address => RoleType) internal bearer; // Members's address that bear the role.

    // add role to members
    function addMember(address _address, RoleType role) public {
      // Members need to have default role to be added
        require(hasRole(_address) == RoleType.NONE, "You already have role");
        bearer[_address] = role;
        members.push(_address);
    }

    // Remove role from members (set role to default)
    function removeMember(address _address) public {
      // Member need to have role (not default)
        require(hasRole(_address) != RoleType.NONE, "Not a member");
        bearer[_address] = RoleType.NONE;
    }

    // Check for role of a member
    function hasRole(address _address) public view returns (RoleType) {
        return bearer[_address];
    }

    // Get all member's address with specific role
    function getMembersWithRole(
        RoleType role
    ) public view returns (address[] memory) {
        address[] memory result = new address[](members.length);
        uint256 counter = 0;
        for (uint256 i = 0; i < members.length; i++) {
            if (bearer[members[i]] == role) {
                result[counter] = members[i];
                counter++;
            }
        }
        return result;
    }
}
