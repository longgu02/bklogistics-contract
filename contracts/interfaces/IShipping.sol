// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IShipping
 * @dev Interface for managing shipments.
 */
interface IShipping {
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
     * @dev Enum defining the status of a shipment.
     */
    enum ShippingStatus {
        NOT_STARTED,
        IN_PROGRESS,
        DELIVERED
    }

    /**
     * @dev Event triggered when a new shipment is created.
     * @param orderDetails The details of the new shipment.
     * @param creator The address of the creator of the shipment.
     * @param createdDate The date the shipment was created.
     */
    event ShippingOrderCreated(
        Shipment orderDetails,
        address creator,
        uint256 createdDate
    );

    /**
     * @dev Event triggered when a shipment is updated.
     * @param orderDetails The details of the updated shipment.
     * @param updater The address of the updater of the shipment.
     * @param updatedDate The date the shipment was updated.
     */
    event ShippingOrderUpdated(
        Shipment orderDetails,
        address updater,
        uint256 updatedDate
    );

    /**
     * @dev Creates a new shipment.
     * @param _orderId The ID of the order associated with the shipment.
     * @param _sender The address of the sender of the shipment.
     * @param _carrier The address of the carrier of the shipment.
     * @param _receiver The address of the receiver of the shipment.
     * @param _pickupDate The date the shipment was picked up.
     */
    function createShipment(
        uint256 _orderId,
        address _sender,
        address _carrier,
        address _receiver,
        uint256 _pickupDate
    ) external returns (uint);

    /**
     * @dev Updates an existing shipment.
     * @param _shipmentId The ID of the shipment to update.
     * @param _deliveryDate The date the shipment was delivered.
     * @param _status The new status of the shipment.
     */
    function updateShipment(
        uint256 _shipmentId,
        uint256 _deliveryDate,
        ShippingStatus _status
    ) external;

    /**
     * @dev Returns the shipment details for the given shipment ID.
     * @param _shipmentId The ID of the shipment to retrieve.
     * @return id The ID of the shipment.
     * @return orderId The ID of the order associated with the shipment.
     * @return sender The address of the sender who initiated the shipment.
     * @return carrier The address of the carrier responsible for transporting the shipment.
     * @return receiver The address of the recipient who will receive the shipment.
     * @return pickupDate The date when the shipment was picked up by the carrier.
     * @return deliveryDate The date when the shipment was delivered to the recipient.
     * @return status The current status of the shipment.
     */
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
        );
}
