// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title ISupplyChain
 * @dev This interface defines the functions and events used by the SupplyChain contract.
 */

interface ISupplyChain {
    /**
     * @dev Enum representing the status of an order.
     */
    enum OrderStatus {
        PENDING, // Recently created
        SUPPLIED, // Supplier finished
        DELIVERING, // Manufacturer finished
        SUCCESS, // Customer received
        FAILED, // Customer rejected or order stay up for too long
        CANCELLED // Order cancelled
    }

    /**
     * @dev Event emitted when a new order is created.
     * @param id The ID of the order.
     * @param productId The ID of the product being ordered.
     * @param customer The address of the customer who placed the order.
     * @param suppliers An array of addresses representing the suppliers for the order.
     * @param manufacturers An array of addresses representing the manufacturers for the order.
     * @param createdDate The timestamp when the order was created.
     * @param creator The address of the user who created the order.
     */

    event OrderCreated(
        uint256 id,
        uint256 productId,
        address customer,
        address[] suppliers,
        address[] manufacturers,
        uint256 createdDate,
        address creator
    );

    /**
     * @dev Event emitted when an order is cancelled.
     * @param id The ID of the order.
     * @param cancelledAddress The address of the user who cancelled the order.
     * @param prevStatus The previous status of the order.
     * @param cancelledDate The timestamp when the order was cancelled.
     */

    event OrderCancelled(
        uint id,
        address cancelledAddress,
        OrderStatus prevStatus,
        uint256 cancelledDate
    );

    /**
     * @dev Event emitted when an order is updated.
     * @param id The ID of the order.
     * @param updatedAddress The address of the user who updated the order.
     * @param updatedDate The timestamp when the order was updated.
     */

    event OrderUpdated(uint id, address updatedAddress, uint256 updatedDate);
    /**
     * @dev Event emitted when an order is paid.
     * @param id The ID of the order.
     * @param payer The address of the user who made the payment.
     * @param amount The remaining amount not includes deposit.
     * @param paymentDate The timestamp when the payment was made.
     */
    event OrderPaid(
        uint id,
        address payer,
        uint256 amount,
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
        bool isPaid; // Payment status
        uint256 deposited; // Deposit status
    }

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
    ) external;

    /**
     *@dev Add a price for a specific account to the payment list of an order.
     *@param _orderId The ID of the order to add the price to.
     *@param _account The account to add the price for.
     *@param price The price to add for the specified account, in ether.
     *Requirements:
     *The function must be called by the customer of the order.
     *The specified order must exist.
     *The specified account must be either a supplier or a manufacturer of the order.
     */

    function addPrice(
        uint256 _orderId,
        address _account,
        uint256 price
    ) external;

    /**
     * @dev Order confirmation step:
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
     * @param _orderId order id
     */
    function confirmOrder(uint256 _orderId) external;

    /**
     * @dev retrive order's details
     * @param _orderId order id
     */
    function viewOrder(
        uint _orderId
    )
        external
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
        );

    /**
     * @dev Cancel the order when its status is not SUCCESS or FAILED
     * @param _orderId order id
     */
    function cancelOrder(uint _orderId) external;

    /*========PAYMENT==========*/

    /**
     * @dev Get total price customer need to pay of an order
     * @param _orderId  order id
     */
    function getTotalPrice(uint _orderId) external view returns (uint256);

    /**
     * @dev Order deposit for customer (20% of total price)
     * @param _orderId order id
     */
    function deposit(uint _orderId) external payable;

    /**
     * @dev Pay order for customer
     * @param _orderId order id
     */
    function payOrder(uint _orderId) external payable;

    /**
     * @dev Pay order's stakeholders with corresponding amount
     * @param _orderId order id
     */
    function _paySteakHolders(uint _orderId) external payable;
}
