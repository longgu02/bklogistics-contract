// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "../Product.sol";

contract Utils {
    function isIncludeAddress(
        address[] memory _arr,
        address _address
    ) public pure returns (bool) {
        for (uint i = 0; i < _arr.length; i++) {
            if (_arr[i] == _address) return true;
        }
        return false;
    }

    function isStakeHolder(
        address[] memory _suppliers,
        address[] memory _manufacturers,
        address _customer,
        address _sender
    ) public pure returns (bool) {
        if (_sender == _customer) {
            return true;
        } else if (isIncludeAddress(_manufacturers, _sender)) {
            return true;
        } else if (isIncludeAddress(_suppliers, _sender)) {
            return true;
        } else {
            return false;
        }
    }
}
