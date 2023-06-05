// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Roles.sol";

contract Pricing {
    Roles roleContract;

    struct Price {
        uint unit;
        uint manufacturePrice;
        uint supplyPrice;
        bool isInit;
    }

    enum PriceType {
        SUPPLY,
        MANUFACTURE
    }
    mapping(address => Price) memberPricing;
    address private roleContractAddress;

    constructor(address _roleContractAddress) {
        roleContract = Roles(_roleContractAddress);
        roleContractAddress = _roleContractAddress;
    }

    modifier onlyRoleContract() {
        require(msg.sender == roleContractAddress, "Permission denied");
        _;
    }

    function modifyPrice(uint _price, PriceType _type) public {
        require(
            _type == PriceType.SUPPLY || _type == PriceType.MANUFACTURE,
            "Please specify price type of manufacture or supply"
        );
        if (_type == PriceType.SUPPLY) {
            memberPricing[msg.sender].supplyPrice = _price;
        } else if (_type == PriceType.MANUFACTURE) {
            memberPricing[msg.sender].manufacturePrice = _price;
        }
        return;
    }

    function initial(address _account) external onlyRoleContract {
        require(
            memberPricing[_account].isInit == false,
            "The address already initialized"
        );
        memberPricing[_account].isInit == true;
        memberPricing[_account].manufacturePrice == 0;
        memberPricing[_account].supplyPrice == 0;
        return;
    }
}
