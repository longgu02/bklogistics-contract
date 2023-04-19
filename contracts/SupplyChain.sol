// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Role.sol";
import "./Product.sol";

contract SupplyChain {

  Roles roleContract; 
  Products private productContract; 
  address private admin;

  enum OrderStatus {
    PENDING,
    SUPPLIED,
    DELIVERING,
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

  }

  Order[] public orderList;

  constructor(address _roleContract, address _productContract){
    roleContract = Roles(_roleContract);
    productContract = Products(_productContract);
    admin = msg.sender;
  }

  //   modifier onlyCustomer(){
  //   require(roleContract.hasRole(msg.sender) == roleContract.RoleType.CUSTOMER );
  // }

  modifier onlyStockHolders(uint256 _orderId){
    Order memory matchedOrder = orderList[_orderId];
    require(msg.sender == matchedOrder.manufacturer || msg.sender == matchedOrder.supplier || msg.sender == matchedOrder.customer, "You are not stakeholder of this order");
  }

  modifier onlyCustomer{
    require(roleContract.hasRole(msg.sender) == Roles.RoleType.CUSTOMER, "You are not customer");
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
        paidStatus : false
    });
    orderList.push(newOrder);
}


  function confirmOrder(uint256 _orderId) onlyStockHolders(_orderId) public returns (bool){
    Roles.RoleType role = roleContract.hasRole(msg.sender);

    if(role == Roles.RoleType.SUPPILER){
      orderList[_orderId].status = OrderStatus.SUPPLIED;
    }else if(role == Roles.RoleType.MANUFACTURER){
      orderList[_orderId].status = OrderStatus.DELIVERING;
    }else if(role == Roles.RoleType.CUSTOMER){
      orderList[_orderId].status = OrderStatus.SUCCESS;
    }
    return true;
  }

  function shipOrder() public view {}

  function viewOrder() public view {}

}
