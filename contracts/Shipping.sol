// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Roles.sol";
import "./SupplyChain.sol";
import "./interfaces/IShipping.sol";

/**
 * @title Shipmnet logic
 * @author Pham Tuan Long - Group 13
 * @notice Shipping management logic | Require role CARRIER for shipping provider
 */

contract Shipping is IShipping {
    Roles public roleContract;
    SupplyChain public supplyChainContract;
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

    modifier onlyRole(bytes32 role) {
        require(
            roleContract.hasRole(role, msg.sender),
            "Caller is not authorized."
        );
        _;
    }

    constructor(
        address _roleContractAddress,
        address _supplyChainContractAddress
    ) {
        roleContract = Roles(_roleContractAddress);
        supplyChainContract = SupplyChain(_supplyChainContractAddress);
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
    ) public onlyRole(roleContract.CARRIER_ROLE()) returns (uint) {
        require(
            _orderId <= supplyChainContract.orderCounter(),
            "Order ID not valid"
        );
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
        emit ShippingOrderCreated(newShipment, msg.sender, block.timestamp);
        return newShipment.id;
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
    ) public onlyRole(roleContract.CARRIER_ROLE()) {
        require(_shipmentId < shipmentCounter, "Invalid shipment ID");
        require(
            msg.sender == shipmentList[_shipmentId].carrier,
            "Only carrier can update shipment status"
        );
        shipmentList[_shipmentId].deliveryDate = _deliveryDate;
        shipmentList[_shipmentId].status = _status;
        emit ShippingOrderUpdated(
            shipmentList[_shipmentId],
            msg.sender,
            block.timestamp
        );
    }

    function sign(uint256 _shipmentId) public {
        require(_shipmentId < shipmentCounter, "Invalid shipment ID");
        require(
            msg.sender == shipmentList[_shipmentId].receiver,
            "Only receiver can sign the shipment"
        );
        shipmentList[_shipmentId].status = ShippingStatus.DELIVERED;
        emit ShippingOrderUpdated(
            shipmentList[_shipmentId],
            msg.sender,
            block.timestamp
        );
    }

    function shipmentOfOrder(
        uint _orderId
    ) public returns (uint[] memory orderIds) {}

    function viewShipment(
        uint256 _shipmentId
    )
        external
        view
        returns (
            uint256 id,
            uint256 orderId,
            address sender,
            address carrier,
            address receiver,
            uint256 pickupDate,
            uint256 deliveryDate,
            ShippingStatus status
        )
    {
        Shipment memory matchedShip = shipmentList[_shipmentId];
        return (
            matchedShip.id,
            matchedShip.orderId,
            matchedShip.sender,
            matchedShip.carrier,
            matchedShip.receiver,
            matchedShip.pickupDate,
            matchedShip.deliveryDate,
            matchedShip.status
        );
    }
}
