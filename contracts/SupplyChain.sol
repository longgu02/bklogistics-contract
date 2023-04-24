// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Role.sol";
import "./Product.sol";
import "./utils/Utils.sol";

contract SupplyChain {

  Roles roleContract; 
  Products private productContract; 
  Utils private utilityContract;
  address private admin;

  enum OrderStatus {
    PENDING, // Recently created
    SUPPLIED, // Supplier finished
    DELIVERING, // Manufacturer finished
    SUCCESS, // Customer received 
    FAILED, // Customer rejected or order stay up for too long
    CANCELLED // Order cancelled
  }


  struct Order {
    uint256 id; // Order ID
    uint256 productId; // Product ID
    address customer; // Customer address
    address[] suppliers; // Supplier address
    address[] manufacturers; // Manufacturer address
    uint256 createdDate; // Order created date
    uint256[] supplyPrice; // Money supplier received after finish the order
    uint256[] manufacturePrice; // Money supplier received after finish the order
    OrderStatus status; // Order's status
    bool paidStatus; // Payment status

  }

  Order[] public orderList;

  constructor(address _roleContract, address _productContract, address _utilityContract){
    roleContract = Roles(_roleContract);
    productContract = Products(_productContract);
    utilityContract = Utils(_utilityContract);
    // admin for maintenance if needed (Based on government)
    admin = msg.sender;
  }

  modifier onlyStockHolders(uint256 _orderId){
    Order memory matchedOrder = orderList[_orderId];
    require(utilityContract.isStakeHolder(matchedOrder.suppliers, matchedOrder.manufacturers, matchedOrder.customer, msg.sender), "You are not stakeholder of this order");
    _;
  }

  modifier onlyCustomer{
    require(roleContract.hasRole(msg.sender) == Roles.RoleType.CUSTOMER, "You are not customer");
    _;
  }

// Customer can create an order with certain informations
function createOrder(uint256 _productId, address _customer, address[] memory _supplier, address[] memory _manufacturer, uint[] memory _supplyPrice, uint[] memory _manufacturePrice) onlyCustomer public {
    Order memory newOrder = Order({
        id : orderList.length + 1,
        productId: _productId,
        customer : _customer,
        suppliers : _supplier,
        manufacturers : _manufacturer,
        createdDate : block.timestamp,
        supplyPrice : _supplyPrice,
        manufacturePrice : _manufacturePrice,
        status : OrderStatus.PENDING,
        paidStatus : false
    });
    orderList.push(newOrder);
}

 /**
  * Order confirmation step:
  * - Each role confirm the order will change its status to a certain type 
  * that corresponding to the "Work has been done" to each role
  *   + Supplier -> Change "pending" to "supplied"
  *   + Manufacturer -> Change "supplied" to "delivering"
  *   + Customer -> Change "delivering" to "success"
  * Note: The confirmation must follow the confirming order of supply chain: Supplier -> Manufacturer -> Customer
  * Any other order is not allowed
  */ 
  function confirmOrder(uint256 _orderId) onlyStockHolders(_orderId) public{
    Roles.RoleType role = roleContract.hasRole(msg.sender);
    // Status changed corresponding to caller role
    if(role == Roles.RoleType.SUPPILER){
      require(orderList[_orderId].status == OrderStatus.PENDING, "Order is not pending");
      orderList[_orderId].status = OrderStatus.SUPPLIED;
    }else if(role == Roles.RoleType.MANUFACTURER){
      require(orderList[_orderId].status == OrderStatus.SUPPLIED, "Order is not supplied");
      orderList[_orderId].status = OrderStatus.DELIVERING;
    }else if(role == Roles.RoleType.CUSTOMER){
      require(orderList[_orderId].status == OrderStatus.DELIVERING, "Order is not delivering");
      orderList[_orderId].status = OrderStatus.SUCCESS;
    }
  }

  // Get order by orderId
  function viewOrder(uint _orderId) public view returns (Order memory) {
    Order memory matchedOrder = orderList[_orderId - 1];
    return matchedOrder;
  }

  // Cancel the order
  function cancelOrder(uint _orderId) public returns (bool) {
    require(_orderId < orderList.length && orderList[_orderId - 1].status != OrderStatus.FAILED, "Order is not valid");
    orderList[_orderId - 1].status = OrderStatus.CANCELLED;
    return true;
  }

}
