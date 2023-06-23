// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Roles.sol";
import "./Product.sol";
import "./utils/Utils.sol";
import "./interfaces/ISupplyChain.sol";

/**
 * @title Supply chain management logic
 * @author Pham Tuan Long - Group 13
 * @notice Only addresses with MEMBER role can interact
 */

contract SupplyChain is ISupplyChain, Roles, Utils {
    Roles private roleContract;
    Products private productContract;
    // Utils private utilityContract;
    address private admin;

    enum OrderRole {
        SUPPLIER,
        MANUFACTURER,
        CUSTOMER
    }

    mapping(uint => mapping(address => bool)) orderSignature;

    mapping(OrderRole => StatusAllowed) public confirmPermission;
    OrderRole[] private initialOrderRole = new OrderRole[](0);

    struct StatusAllowed {
        OrderStatus statusSet;
        OrderStatus prevStatus;
    }

    mapping(uint => Order) orderList;
    mapping(uint => uint) public totalPrice;
    mapping(uint => OrderPayment) paymentList; // Payment for order in orderList (corresponding id)
    uint public orderCounter;

    constructor(address _roleContract, address _productContract) {
        roleContract = Roles(_roleContract);
        productContract = Products(_productContract);
        admin = msg.sender;
        orderCounter = 1;
    }

    modifier onlyStakeHolder(uint256 _orderId) {
        Order storage matchedOrder = orderList[_orderId];
        require(
            isStakeHolder(
                matchedOrder.suppliers,
                matchedOrder.manufacturers,
                matchedOrder.customer,
                msg.sender
            ),
            "You are not stakeholder of this order"
        );
        _;
    }

    modifier onlyCustomer(uint _orderId) {
        require(
            roleContract.hasRole(roleContract.MEMBER_ROLE(), msg.sender),
            "You are not a member"
        );
        require(
            orderList[_orderId].customer == msg.sender,
            "You are not customer"
        );
        _;
    }

    function _checkRole(
        bytes32 role,
        address account
    ) internal view virtual override {
        if (!roleContract.hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    // Customer can create an order with certain informations
    /**
     * @dev create an order
     * @param _productId product id
     * @param _customer customer address
     * @param _supplier suppliers address array
     * @param _manufacturer manufacturer address array
     */
    function createOrder(
        uint256 _productId,
        address _customer,
        address[] memory _supplier,
        address[] memory _manufacturer
    ) public onlyRole(roleContract.MEMBER_ROLE()) {
        // product id valid
        // require(_productId <= productContract.productCounter(), "Product not exist");
        // suppliers are member
        for (uint i = 0; i < _supplier.length; i++) {
            require(
                roleContract.hasRole(roleContract.MEMBER_ROLE(), _supplier[i]),
                "a supplier is not a member"
            );
        }
        // manufacturers are member
        for (uint i = 0; i < _manufacturer.length; i++) {
            require(
                roleContract.hasRole(
                    roleContract.MEMBER_ROLE(),
                    _manufacturer[i]
                ),
                "a manufacturer is not a member"
            );
        }
        Order memory newOrder = Order({
            id: orderCounter,
            productId: _productId,
            customer: _customer,
            suppliers: _supplier,
            manufacturers: _manufacturer,
            createdDate: block.timestamp,
            status: OrderStatus.PENDING,
            isPaid: false,
            deposited: 0,
            numberOfSigned: 0
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
        // Deposit 20%
    }

    function addPrice(
        uint256 _orderId,
        address[] memory _accounts,
        uint256[] memory _productIds,
        uint256[] memory _prices,
        uint256[] memory _qty
    ) public onlyCustomer(_orderId) {
        require(
            orderList[_orderId].customer == msg.sender,
            "You are not customer"
        );
        for (uint i = 0; i < _accounts.length; i++) {
            paymentList[_orderId].price[_accounts[i]] +=
                _prices[i] *
                _qty[i] *
                1 wei;
            paymentList[_orderId].detail[_accounts[i]].productId = _productIds[
                i
            ];
            paymentList[_orderId].detail[_accounts[i]].quantity = _qty[i];
            totalPrice[_orderId] += _prices[i] * _qty[i] * 1 wei;
        }
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
    function confirmOrder(uint256 _orderId) public onlyStakeHolder(_orderId) {
        require(
            roleContract.hasRole(roleContract.MEMBER_ROLE(), msg.sender),
            "Not a member"
        );
        require(_orderId <= orderCounter, "Order ID is not valid");
        require(
            orderSignature[_orderId][msg.sender] = true,
            "You have already signed"
        );
        if (orderList[_orderId].customer == msg.sender) {
            require(
                orderList[_orderId].isPaid == true,
                "You need to pay the order"
            );
        }
        orderSignature[_orderId][msg.sender] = true;
        orderList[_orderId].numberOfSigned++;
        uint numberOfManufacturers = orderList[_orderId].manufacturers.length;
        uint numberOfSuppliers = orderList[_orderId].suppliers.length;
        if (
            orderList[_orderId].numberOfSigned ==
            numberOfManufacturers + numberOfSuppliers + 1
        ) {
            orderList[_orderId].status = OrderStatus.SUCCESS;
        }
        // bool confirmed = false;
        // Order memory order = orderList[_orderId];
        // // Status changed corresponding to caller role
        // OrderRole[] storage callerRoles = _getOrderRoles(_orderId, msg.sender);
        // for (uint i = 0; i < callerRoles.length; i++) {
        //     if (confirmPermission[callerRoles[i]].prevStatus == order.status) {
        //         orderList[_orderId].status = confirmPermission[callerRoles[i]]
        //             .statusSet;
        //         confirmed = true;
        //     }
        // }
        // if (confirmed) {
        //     emit OrderUpdated(_orderId, msg.sender, block.timestamp);
        // } else {
        //     revert("Not your turn to confirm");
        // }
    }

    /**
     * @dev retrive order's details
     * @param _orderId order id
     */

    function viewOrder(
        uint _orderId
    )
        public
        view
        returns (
            uint256 id,
            uint256 productId,
            address customer,
            address[] memory suppliers,
            address[] memory manufacturers,
            uint256 createdDate,
            OrderStatus status,
            bool isPaid,
            uint256 deposited
        )
    {
        require(_orderId <= orderCounter, "Order ID is not valid");
        Order memory matchedOrder = orderList[_orderId];
        return (
            matchedOrder.id,
            matchedOrder.productId,
            matchedOrder.customer,
            matchedOrder.suppliers,
            matchedOrder.manufacturers,
            matchedOrder.createdDate,
            matchedOrder.status,
            matchedOrder.isPaid,
            matchedOrder.deposited
        );
    }

    function viewOrderStakeholderDetail(
        uint _orderId,
        address _account
    ) public view returns (uint productId, uint quantity, uint price) {
        OrderPayment storage orderInvoice = paymentList[_orderId];
        return (
            orderInvoice.detail[_account].productId,
            orderInvoice.detail[_account].quantity,
            orderInvoice.price[_account]
        );
    }

    /**
     * @dev Cancel the order when its status is not SUCCESS or FAILED
     * @param _orderId order id
     */

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

    /**
     * @dev Check if the caller is order stakeholder and its role
     * @param _orderId order id
     * @param _caller the caller address
     */
    function _getOrderRoles(
        uint _orderId,
        address _caller
    ) private returns (OrderRole[] storage) {
        require(_orderId <= orderCounter, "Order is not valid");
        Order memory matchedOrder = orderList[_orderId]; // Need to check for potiential bug
        OrderRole[] storage roles = initialOrderRole; // initialize roles to an empty array
        address customer = matchedOrder.customer;
        if (_caller == customer) {
            roles.push(OrderRole.CUSTOMER);
        }

        address[] memory suppliers = matchedOrder.suppliers;
        address[] memory manufacturers = matchedOrder.manufacturers;

        for (uint i = 0; i < suppliers.length; i++) {
            if (_caller == suppliers[i]) {
                roles.push(OrderRole.SUPPLIER);
                break;
            }
        }
        for (uint i = 0; i < manufacturers.length; i++) {
            if (_caller == manufacturers[i]) {
                roles.push(OrderRole.MANUFACTURER);
                break;
            }
        }
        return roles;
    }

    /*========PAYMENT==========*/

    /**
     * @dev Get total price customer need to pay of an order
     * @param _orderId  order id
     */

    function getTotalPrice(uint _orderId) public view returns (uint256) {
        require(_orderId < orderCounter, "No order found");
        return totalPrice[_orderId];
    }

    /**
     * @dev Order deposit for customer (20% of total price)
     * @param _orderId order id
     */

    function deposit(uint _orderId) public payable onlyCustomer(_orderId) {
        require(_orderId < orderCounter, "No order found");
        uint256 total = totalPrice[_orderId];
        uint256 depositAmount = total / 5; // Deposit 20% of total price
        require(msg.value >= depositAmount, "Not enough deposit amount");
        orderList[_orderId].deposited = msg.value;
        orderList[_orderId].status = OrderStatus.IN_PROGRESS;
    }

    /**
     * @dev Pay order for customer
     * @param _orderId order id
     */

    function payOrder(uint _orderId) public payable onlyCustomer(_orderId) {
        require(_orderId < orderCounter, "No order found");
        uint256 total = totalPrice[_orderId];
        uint256 payAmount = total - orderList[_orderId].deposited; // Deposit 20% of total price
        require(msg.value >= payAmount, "Not enough");
        orderList[_orderId].isPaid = true;
        confirmOrder(_orderId);
        _paySteakHolders(_orderId);
    }

    /**
     * @dev Pay order's stakeholders with corresponding amount
     * @param _orderId order id
     */
    function _paySteakHolders(
        uint _orderId
    ) public payable onlyCustomer(_orderId) {
        require(orderList[_orderId].isPaid, "Order is not paid");
        require(
            orderList[_orderId].status == OrderStatus.SUCCESS,
            "Order is not confirmed"
        );
        Order memory matchedOrder = orderList[_orderId];
        for (uint i = 0; i < matchedOrder.suppliers.length; i++) {
            _transferFunds(
                payable(matchedOrder.suppliers[i]),
                paymentList[_orderId].price[matchedOrder.suppliers[i]]
            );
        }
        for (uint i = 0; i < matchedOrder.manufacturers.length; i++) {
            _transferFunds(
                payable(matchedOrder.manufacturers[i]),
                paymentList[_orderId].price[matchedOrder.manufacturers[i]]
            );
        }
    }

    /**
     * Transfer function for contract
     */
    function _transferFunds(address payable _to, uint _amount) private {
        require(address(this).balance >= _amount, "Insufficient balance");
        _to.transfer(_amount);
    }
}
