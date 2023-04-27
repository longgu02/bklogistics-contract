// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "node_modules/@openzeppelin/contracts/access/AccessControl.sol";

contract Shipping is AccessControl {
    
    enum ShippingStatus {NOT_STARTED, IN_PROGRESS, DELIVERED}
    
    struct Shipment {
        uint256 id;
        uint256 orderId;
        address carrier;
        uint256 pickupDate;
        uint256 deliveryDate;
        ShippingStatus status;
    }
    
    mapping(uint256 => Shipment) public shipmentList;
    uint256 public shipmentCounter;
    
    bytes32 public constant CARRIER_ROLE = keccak256("CARRIER_ROLE");
    
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CARRIER_ROLE, msg.sender);
    }
    
    function createShipment(uint256 _orderId, address _carrier, uint256 _pickupDate) onlyRole(CARRIER_ROLE) public {
        Shipment memory newShipment = Shipment({
            id: shipmentCounter,
            orderId: _orderId,
            carrier: _carrier,
            pickupDate: _pickupDate,
            deliveryDate: 0,
            status: ShippingStatus.NOT_STARTED
        });
        shipmentList[shipmentCounter] = newShipment;
        shipmentCounter++;
    }
    
    function updateShipment(uint256 _shipmentId, uint256 _deliveryDate, ShippingStatus _status) onlyRole(CARRIER_ROLE) public {
        require(_shipmentId < shipmentCounter, "Invalid shipment ID");
        Shipment storage shipment = shipmentList[_shipmentId];
        require(msg.sender == shipment.carrier, "Only carrier can update shipment status");
        shipment.deliveryDate = _deliveryDate;
        shipment.status = _status;
    }
}