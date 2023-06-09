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

    struct PartialPrice {
        uint price;
        Unit unit;
    }

    struct Price {
        PartialPrice manufacturePrice;
        PartialPrice supplyPrice;
    }

    struct MemberPricing {
        mapping(uint => Price) productPrice;
    }

    enum PriceType {
        SUPPLY,
        MANUFACTURE
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
        uint productId,
        uint _price,
        uint8 _type,
        Unit _unit
    ) public {
        PriceType priceType = PriceType(_type);
        require(
            priceType == PriceType.SUPPLY || priceType == PriceType.MANUFACTURE,
            "Please specify price type of manufacture or supply"
        );
        require(
            productId < productContract.productCounter(),
            "Product not found"
        );
        PartialPrice memory newPrice = PartialPrice({
            price: _price * 1 wei,
            unit: _unit
        });
        if (priceType == PriceType.SUPPLY) {
            memberPricing[msg.sender]
                .productPrice[productId]
                .supplyPrice = newPrice;
        } else if (priceType == PriceType.MANUFACTURE) {
            memberPricing[msg.sender]
                .productPrice[productId]
                .manufacturePrice = newPrice;
        }
        emit PriceUpdated(msg.sender, productId, priceType, _price, _unit);
        return;
    }

    function getPrice(
        address _account,
        uint _productId,
        PriceType _type
    ) public view returns (uint productId, uint price, Unit unit) {
        Price memory matchedPricing = memberPricing[_account].productPrice[
            _productId
        ];
        if (_type == PriceType.MANUFACTURE) {
            return (
                _productId,
                matchedPricing.manufacturePrice.price,
                matchedPricing.manufacturePrice.unit
            );
        } else if (_type == PriceType.SUPPLY) {
            return (
                _productId,
                matchedPricing.supplyPrice.price,
                matchedPricing.supplyPrice.unit
            );
        } else {
            revert("Unknown type");
        }
    }
}
