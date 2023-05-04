// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Roles.sol";

contract Products {
    /**
     * @title Products
     * @dev This contract allows the creation, retrieval, update and deletion of products in a supply chain management system.
     */

    Roles private roleContract;

    struct Product {
        uint256 productId; // Product unique identifier
        string name; // Product name
    }

    mapping(uint => Product) products; // Mapping of product ID to product details
    uint private productCounter; // Counter for total number of products added to the system

    constructor(address _roleContract) {
        roleContract = Roles(_roleContract);
    }

    event ProductAdded(
        uint256 productId,
        string name,
        uint256 price,
        uint256 quantity
    );

    /**
     * @dev Adds a new product to the system.
     * @param _name Name of the new product.
     * @param _price Price of the new product.
     * @param _quantity Quantity of the new product.
     */

    function addProduct(
        string memory _name,
        uint _price,
        uint _quantity
    ) public {
        require(_price > 0, "Price must be greater than 0");
        require(_quantity > 0, "Quantity must be greater than 0");

        // Check if product with the same name already exists
        for (uint i = 0; i < productCounter; i++) {
            if (keccak256(bytes(products[i].name)) == keccak256(bytes(_name))) {
                revert("Product with same name already exists");
            }
        }

        // Add new product
        Product memory newProduct = Product(
            productCounter,
            _name,
            _price,
            _quantity
        );
        products[productCounter] = newProduct;
        productCounter++;
    }

    /**
     * @dev Gets the details of a product given the product ID.
     * @param _productId ID of the product to be retrieved.
     * @return Product details of the product with the given ID.
     */

    function getProduct(
        uint256 _productId
    ) public view returns (Product memory) {
        require(
            _productId > 0 && _productId <= productCounter,
            "Invalid product ID"
        );
        return products[_productId - 1];
    }

    /**
     * @dev Updates the details of a product given the product ID.
     * @param _productId ID of the product to be updated.
     * @param _name New name of the product.
     * @param _price New price of the product.
     * @param _quantity New quantity of the product.
     */

    function updateProduct(
        uint256 _productId,
        string memory _name,
        uint256 _price,
        uint256 _quantity
    ) public {
        require(
            _productId > 0 && _productId <= productCounter,
            "Invalid product ID"
        );
        Product storage product = products[_productId - 1];
        product.name = _name;
        product.price = _price;
        product.quantity = _quantity;
    }

    /**
     * @dev Deletes a product given the product ID.
     * @param _productId ID of the product to be deleted.
     */

    function removeProduct(uint256 _productId) public {
        require(
            _productId > 0 && _productId <= productCounter,
            "Invalid product ID"
        );
        delete products[_productId - 1];
    }
}
