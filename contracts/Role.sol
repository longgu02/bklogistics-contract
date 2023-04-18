// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Roles {
    enum RoleType {
        NONE,
        SUPPILER,
        MANUFACTURER,
        CUSTOMER
    }
    address[] members;
    mapping(address => RoleType) internal bearer;

    function addMember(address _address, RoleType role) public {
        require(hasRole(_address) == RoleType.NONE, "You already have role");
        bearer[_address] = role;
        members.push(_address);
    }

    function removeMember(address _address) public {
        require(hasRole(_address) != RoleType.NONE, "Not a member");
        bearer[_address] = RoleType.NONE;
    }

    function hasRole(address _address) public view returns (RoleType) {
        return bearer[_address];
    }

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
