// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Roles.sol";
import "./Product.sol";
import "./utils/Utils.sol";

contract SupplyChain is Roles {
    Roles private roleContract;
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

    mapping(bytes32 => StatusAllowed) private _roleUpdatePermission;

    struct StatusAllowed {
        OrderStatus statusSet;
        OrderStatus prevStatus;
    }

    event OrderCreated(
        uint256 id,
        uint256 productId,
        address customer,
        address[] suppliers,
        address[] manufacturers,
        uint256 createdDate,
        address creator
    );

    event OrderCancelled(
        uint id,
        address cancelledAddress,
        OrderStatus prevStatus,
        uint256 cancelledDate
    );

    event OrderUpdated(
        uint id,
        address updatedAddress,
        bytes32 role,
        OrderStatus prevStatus,
        OrderStatus curStatus,
        uint256 updatedDate
    );

    event OrderPaid(
        uint id,
        address payer,
        address[] receivers,
        uint256[] amount,
        uint256 paymentDate
    );

    struct OrderPayment {
        mapping(address => uint) price; // Money stakeholders received after finish the order
    }

    struct Order {
        uint256 id; // Order ID
        uint256 productId; // Product ID
        address customer; // Customer address
        address[] suppliers; // Supplier address
        address[] manufacturers; // Manufacturer address
        uint256 createdDate; // Order created date
        OrderStatus status; // Order's status
        bool paidStatus; // Payment status
    }

    mapping(uint => Order) orderList;
    mapping(uint => OrderPayment) paymentList; // Payment for order in orderList (corresponding id)
    uint orderCounter;

    constructor(
        address _roleContract,
        address _productContract,
        address _utilityContract
    ) {
        roleContract = Roles(_roleContract);
        productContract = Products(_productContract);
        utilityContract = Utils(_utilityContract);
        // admin for maintenance if needed (Based on government)
        admin = msg.sender;
        _roleUpdatePermission[SUPPLIER_ROLE] = StatusAllowed(
            OrderStatus.SUPPLIED,
            OrderStatus.PENDING
        );
        _roleUpdatePermission[MANUFACTURER_ROLE] = StatusAllowed(
            OrderStatus.DELIVERING,
            OrderStatus.SUPPLIED
        );
        _roleUpdatePermission[CUSTOMER_ROLE] = StatusAllowed(
            OrderStatus.SUCCESS,
            OrderStatus.DELIVERING
        );
        orderCounter = 1;
    }

    modifier onlyStakeHolder(uint256 _orderId) {
        Order storage matchedOrder = orderList[_orderId];
        require(
            utilityContract.isStakeHolder(
                matchedOrder.suppliers,
                matchedOrder.manufacturers,
                matchedOrder.customer,
                msg.sender
            ),
            "You are not stakeholder of this order"
        );
        _;
    }

    modifier onlyCustomer() {
        require(
            roleContract.hasRole(CUSTOMER_ROLE, msg.sender),
            "You are not customer"
        );
        _;
    }

    // modifier onlyCustomer{
    //   require(roleContract.hasRole() == CUSTOMER_ROLE, "You are not customer");
    //   _;
    // }

    // Customer can create an order with certain informations
    function createOrder(
        uint256 _productId,
        address _customer,
        address[] memory _supplier,
        address[] memory _manufacturer
    ) public onlyCustomer {
        Order memory newOrder = Order({
            id: orderCounter,
            productId: _productId,
            customer: _customer,
            suppliers: _supplier,
            manufacturers: _manufacturer,
            createdDate: block.timestamp,
            status: OrderStatus.PENDING,
            paidStatus: false
        });
        emit OrderCreated(
            newOrder.id,
            newOrder.productId,
            newOrder.customer,
            newOrder.suppliers,
            newOrder.manufacturers,
            block.timestamp,
            msg.sender
        );
        orderList[orderCounter] = newOrder;
        orderCounter++;
    }

    function addPrice(
        uint256 _orderId,
        address _account,
        uint256 price
    ) public onlyCustomer {
        require(
            orderList[_orderId].customer == msg.sender,
            "You are not customer"
        );
        paymentList[_orderId].price[_account] = price;
    }

    /**
     * Order confirmation step:
     *
     * - Each role confirm the order will change its status to a certain type
     * that corresponding to the "Work has been done" to each role
     *
     *   + Supplier -> Change "pending" to "supplied"
     *   + Manufacturer -> Change "supplied" to "delivering"
     *   + Customer -> Change "delivering" to "success"
     *
     * Note: The confirmation must follow the confirming order of supply chain: Supplier -> Manufacturer -> Customer
     * Any other order is not allowed
     */
    function confirmOrder(
        uint256 _orderId,
        bytes32 _role
    ) public onlyStakeHolder(_orderId) {
        require(roleContract.hasRole(_role, msg.sender), "Role not granted");
        require(_orderId <= orderCounter, "Order ID is not valid");
        // Status changed corresponding to caller role
        require(
            _roleUpdatePermission[_role].prevStatus ==
                orderList[_orderId].status,
            "Current order status is not valid"
        );
        orderList[_orderId].status = _roleUpdatePermission[_role].statusSet;
        emit OrderUpdated(
            _orderId,
            msg.sender,
            _role,
            _roleUpdatePermission[_role].prevStatus,
            _roleUpdatePermission[_role].statusSet,
            block.timestamp
        );
        // if (roleContract.hasRole(SUPPLIER_ROLE, msg.sender)) {
        //     require(
        //         orderList[_orderId].status == OrderStatus.PENDING,
        //         "Order is not currently pending"
        //     );
        //     orderList[_orderId].status = OrderStatus.SUPPLIED;
        // } else if (roleContract.hasRole(MANUFACTURER_ROLE, msg.sender)) {
        //     require(
        //         orderList[_orderId].status == OrderStatus.SUPPLIED,
        //         "Order has not supplied"
        //     );
        //     orderList[_orderId].status = OrderStatus.DELIVERING;
        // } else if (roleContract.hasRole(CUSTOMER_ROLE, msg.sender)) {
        //     require(
        //         orderList[_orderId].status == OrderStatus.DELIVERING,
        //         "Order has not delivering"
        //     );
        //     orderList[_orderId].status = OrderStatus.SUCCESS;
        // }
    }

    // Get order by orderId
    function viewOrder(uint _orderId) public view returns (Order memory) {
        require(_orderId <= orderCounter, "Order ID is not valid");
        Order memory matchedOrder = orderList[_orderId];
        return matchedOrder;
    }

    // Cancel the order
    function cancelOrder(uint _orderId) public {
        require(
            _orderId <= orderCounter &&
                orderList[_orderId].status != OrderStatus.SUCCESS,
            "Order is not valid"
        );
        OrderStatus prevStatus = orderList[_orderId].status;
        orderList[_orderId].status = OrderStatus.CANCELLED;
        emit OrderCancelled(_orderId, msg.sender, prevStatus, block.timestamp);
    }
}
