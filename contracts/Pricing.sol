// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Roles.sol";
import "./Products.sol";

contract Pricing is Roles {
    Roles roleContract;
    Products productContract;

    enum Unit {
        NONE,
        KILOGRAM,
        METER,
        LITTER
    }

    struct Price {
        uint price;
        Unit unit;
        bool isListed;
    }

    struct MemberPricing {
        mapping(uint => Price) productPrice;
        mapping(uint => Price) materialPrice;
    }

    enum PriceType {
        MATERIAL,
        PRODUCT
    }

    event PriceUpdated(
        address updater,
        uint productId,
        PriceType priceType,
        uint price,
        Unit unit
    );

    mapping(address => MemberPricing) memberPricing;
    address private roleContractAddress;

    constructor(address _roleContractAddress, address _productContractAddress) {
        roleContract = Roles(_roleContractAddress);
        roleContractAddress = _roleContractAddress;
        productContract = Products(_productContractAddress);
    }

    modifier onlyRoleContract() {
        require(msg.sender == roleContractAddress, "Permission denied");
        _;
    }

    function modifyPrice(
        uint _id,
        uint _price,
        bool _list,
        uint8 _type,
        Unit _unit
    ) public {
        PriceType priceType = PriceType(_type);
        require(
            priceType == PriceType.MATERIAL || priceType == PriceType.PRODUCT,
            "Please specify price type of manufacture or supply"
        );
        require(_id < productContract.productCounter(), "Product not found");
        Price memory newPrice = Price({
            price: _price * 1 wei,
            unit: _unit,
            isListed: _list
        });
        if (priceType == PriceType.MATERIAL) {
            memberPricing[msg.sender].materialPrice[_id] = newPrice;
        } else if (priceType == PriceType.PRODUCT) {
            memberPricing[msg.sender].productPrice[_id] = newPrice;
        }
        emit PriceUpdated(msg.sender, _id, priceType, _price, _unit);
        return;
    }

    function getPrice(
        address _account,
        uint _id,
        PriceType _type
    )
        public
        view
        returns (uint productId, uint price, Unit unit, bool isListed)
    {
        if (_type == PriceType.PRODUCT) {
            return (
                _id,
                memberPricing[_account].productPrice[_id].price,
                memberPricing[_account].productPrice[_id].unit,
                memberPricing[_account].productPrice[_id].isListed
            );
        } else if (_type == PriceType.MATERIAL) {
            return (
                _id,
                memberPricing[_account].materialPrice[_id].price,
                memberPricing[_account].materialPrice[_id].unit,
                memberPricing[_account].materialPrice[_id].isListed
            );
        } else {
            revert("Unknown type");
        }
    }
}
