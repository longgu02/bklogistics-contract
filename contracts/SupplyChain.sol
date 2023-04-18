// SPDX-License-Identifier: GPL-3.0

import "./Role.sol";
import "./AccessControl.sol";
import "./Product.sol";

pragma solidity >=0.7.0 <0.9.0;

contract SupplyChain {

  Role private roleContract; 
  AccessControl private accessControlContract; 
  Product private productContract; 
  address private admin;

  enum OrderStatus {
    PENDING,
    SUCCESS,
    FAILED
  }

  struct Order {
    uint256 id;
    uint256 productId;
    address customer;
    address supplier;
    address manufacturer;
    uint256 createdDate;
    uint256 supplyPrice;
    uint256 manufacturePrice;
    OrderStatus status;
    bool paidStatus;
    bool isSignedCustomer;
    bool isSignedSupplier;
    bool isSignedManufacturer;

  }

  Order[] public orderList;

  constructor(address _roleContract, address _accessControlContract, address _productContract){
    accessControlContract = AccessControl(_accessControlContract);
    roleContract = Role(_roleContract);
    productContract = Product(_productContract);
    admin = msg.sender;
  }

function createOrder(uint256 _productId, address _customer, address _supplier, address _manufacturer, uint _supplyPrice, uint _manufacturePrice) public {
    Order memory newOrder = Order({
        id : orderList.length + 1,
        productId: _productId,
        customer : _customer,
        supplier : _supplier,
        manufacturer : _manufacturer,
        createdDate : block.timestamp,
        supplyPrice : _supplyPrice,
        manufacturePrice : _manufacturePrice,
        status : OrderStatus.PENDING,
        paidStatus : false,
        isSignedCustomer : false,
        isSignedSupplier : false,
        isSignedManufacturer : false
    });
    orderList.push(newOrder);
}


  function confirmOrder(uint256 _orderId) public view {
    Role.RoleType role = Role.hasRole(msg.sender);
    // The signer must have role to call this function
    require(role != Role.RoleType.NONE, "Permission denied");
    // Check if the signer is stakeholder
    require(msg.sender == orderList[orderId].manufacturer || 
    msg.sender == orderList[orderId].supplier || 
    msg.sender == orderList[orderId].customer, "You are not stakeholder of this order");
    // Check if the signer has signed the order
    // switch(role){
    //   case Role.RoleType.NONE:
    // }
  }

  function shipOrder() public view {}

  function viewOrder() public view {}

}
