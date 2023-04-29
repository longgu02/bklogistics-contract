// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "node_modules/@openzeppelin/contracts/access/AccessControl.sol";

contract Shipping is AccessControl {
    /**
        @title Shipping
        @dev This contract manages shipments and their status updates.
    */

    /**
     * @dev Enum representing the status of a shipment.
     */
    enum ShippingStatus {
        NOT_STARTED,
        IN_PROGRESS,
        DELIVERED
    }
    
    /**
     * @dev Struct representing a shipment.
     * @param id Unique identifier for the shipment.
     * @param orderId Unique identifier for the order associated with the shipment.
     * @param sender Address of the sender of the shipment.
     * @param carrier Address of the carrier handling the shipment.
     * @param receiver Address of the receiver of the shipment.
     * @param pickupDate Date the shipment was picked up.
     * @param deliveryDate Date the shipment was delivered.
     * @param status Status of the shipment.
     */

    struct Shipment {
        uint256 id;
        uint256 orderId;
        address sender;
        address carrier;
        address receiver;
        uint256 pickupDate;
        uint256 deliveryDate;
        ShippingStatus status;
    }

    /**
     * @dev Mapping of shipment IDs to Shipment structs.
     */

    mapping(uint256 => Shipment) public shipmentList;

    /**
     * @dev Counter for the number of shipments in the system.
     */
    uint256 public shipmentCounter;

    bytes32 public constant CARRIER_ROLE = keccak256("CARRIER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor() {
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(CARRIER_ROLE, ADMIN_ROLE);
        shipmentCounter = 1;
    }

    /**
     * @dev Creates a new shipment.
     * @param _orderId Unique identifier for the order associated with the shipment.
     * @param _sender Address of the sender of the shipment.
     * @param _carrier Address of the carrier handling the shipment.
     * @param _receiver Address of the receiver of the shipment.
     * @param _pickupDate Date the shipment was picked up.
     * Can only be called by accounts with the CARRIER_ROLE.
     */

    function createShipment(
        uint256 _orderId,
        address _sender,
        address _carrier,
        address _receiver,
        uint256 _pickupDate
    ) public onlyRole(CARRIER_ROLE) {
        Shipment memory newShipment = Shipment({
            id: shipmentCounter,
            orderId: _orderId,
            sender: _sender,
            carrier: _carrier,
            receiver: _receiver,
            pickupDate: _pickupDate,
            deliveryDate: 0,
            status: ShippingStatus.NOT_STARTED
        });
        shipmentList[shipmentCounter] = newShipment;
        shipmentCounter++;
    }

    /**
     * @dev Grants the CARRIER_ROLE to a specified account.
     * @param _account Address of the account to grant the CARRIER_ROLE to.
     * Can only be called by accounts with the ADMIN_ROLE.
     */
    function addCarrier(address _account) public onlyRole(ADMIN_ROLE) {
        grantRole(CARRIER_ROLE, _account);
    }
    
    /**
     * @dev Renounce the CARRIER_ROLE to a specified account.
     * @param _account Address of the account to renounce the CARRIER_ROLE to.
     * Can only be called by accounts with the CARRIER_ROLE.
     */
    function renounceCarrier(address _account) public onlyRole(CARRIER_ROLE){
        renounceRole(CARRIER_ROLE, _account)
    }

    /**
     * @dev Update an existing shipment.
     * @param _shipmentId Unique identifier for the order associated with the shipment.
     * @param _deliveryDate New delivery date for shipment.
     * @param _status New status for shipment order.
     * Can only be called by accounts with the CARRIER_ROLE.
     */

    function updateShipment(
        uint256 _shipmentId,
        uint256 _deliveryDate,
        ShippingStatus _status
    ) public onlyRole(CARRIER_ROLE) {
        require(_shipmentId < shipmentCounter, "Invalid shipment ID");
        Shipment storage shipment = shipmentList[_shipmentId];
        require(
            msg.sender == shipment.carrier,
            "Only carrier can update shipment status"
        );
        shipment.deliveryDate = _deliveryDate;
        shipment.status = _status;
    }
}
