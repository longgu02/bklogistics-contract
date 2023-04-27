// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Role.sol";
import "./Product.sol";
import "./utils/Utils.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";

contract SupplyChain is Role {

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
    mapping (address => uint) price; // Money stakeholders received after finish the order
    OrderStatus status; // Order's status
    bool paidStatus; // Payment status

  }

  mapping(uint => Order) orderList;
  uint orderCounter;

  constructor(address _productContract, address _utilityContract){
    productContract = Products(_productContract);
    utilityContract = Utils(_utilityContract);
    // admin for maintenance if needed (Based on government)
    admin = msg.sender;
    orderCounter = 1;
  }

  modifier onlyStockHolders(uint256 _orderId){
    Order memory matchedOrder = orderList[_orderId];
    require(utilityContract.isStakeHolder(matchedOrder.suppliers, matchedOrder.manufacturers, matchedOrder.customer, msg.sender), "You are not stakeholder of this order");
    _;
  }

  // modifier onlyCustomer{
  //   require(hasRole() == CUSTOMER_ROLE, "You are not customer");
  //   _;
  // }

// Customer can create an order with certain informations
function createOrder(uint256 _productId, address _customer, address[] memory _supplier, address[] memory _manufacturer, uint[] memory _supplyPrice, uint[] memory _manufacturePrice) onlyRole(CUSTOMER_ROLE) public {
    Order memory newOrder = Order({
        id : orderCounter,
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
      orderList[orderCounter] = newOrder;
      orderCounter++;
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
    require(_orderId <= orderCounter, "Order ID is not valid");
    // Status changed corresponding to caller role
    if(hasRole(SUPPLIER_ROLE ,msg.sender)){
      require(orderList[_orderId].status == OrderStatus.PENDING, "Order is not currently pending");
      orderList[_orderId].status = OrderStatus.SUPPLIED;
    }else if(hasRole(MANUFACTURER_ROLE ,msg.sender)){
      require(orderList[_orderId].status == OrderStatus.SUPPLIED, "Order has not supplied");
      orderList[_orderId].status = OrderStatus.DELIVERING;
    }else if(hasRole(CUSTOMER_ROLE ,msg.sender)){
      require(orderList[_orderId].status == OrderStatus.DELIVERING, "Order has not delivering");
      orderList[_orderId].status = OrderStatus.SUCCESS;
    }
  }

  // Get order by orderId
  function viewOrder(uint _orderId) public view returns (Order memory) {
    require(_orderId <= orderCounter, "Order ID is not valid");
    Order memory matchedOrder = orderList[_orderId];
    return matchedOrder;
  }

  // Cancel the order
  function cancelOrder(uint _orderId) public {
    require(_orderId <= orderCounter && orderList[_orderId].status != OrderStatus.FAILED, "Order is not valid");
    orderList[_orderId].status = OrderStatus.CANCELLED;
  }

}
