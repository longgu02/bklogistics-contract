// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Products {
    struct Product {
        uint256 productId; // Product unique identifier
        string name; // Product name
    }

    mapping(uint => Product) products; // Mapping of product ID to product details
    uint256 public productCounter; // Counter for total number of products added to the system

    event ProductAdded(
        uint256 productId,
        string name,
        address adder,
        uint256 removeDate
    );

    event ProductRemoved(
        uint256 productId,
        address remover,
        uint256 removeDate
    );

    /**
     * @dev Adds a new product to the system.
     * @param _name Name of the new product.
     * emit event ProductAdded
     */

    function addProduct(string memory _name) public {
        // Check if product with the same name already exists
        for (uint i = 0; i < productCounter; i++) {
            if (keccak256(bytes(products[i].name)) == keccak256(bytes(_name))) {
                revert("Product with same name already exists");
            }
        }

        // Add new product
        Product memory newProduct = Product(productCounter, _name);
        products[productCounter] = newProduct;
        productCounter++;
        emit ProductAdded(
            newProduct.productId,
            _name,
            msg.sender,
            block.timestamp
        );
    }

    /**
     * @dev Gets the details of a product given the product ID.
     * @param _productId ID of the product to be retrieved.
     * @return productName Product details of the product with the given ID.
     */

    function getProduct(
        uint256 _productId
    ) public view returns (string memory productName) {
        require(
            _productId > 0 && _productId <= productCounter,
            "Invalid product ID"
        );
        return products[_productId - 1].name;
    }

    /**
     * @dev Updates the details of a product given the product ID.
     * @param _productId ID of the product to be updated.
     * @param _name New name of the product.
     */

    function updateProduct(uint256 _productId, string memory _name) public {
        require(
            _productId > 0 && _productId <= productCounter,
            "Invalid product ID"
        );
        Product storage product = products[_productId - 1];
        product.name = _name;
    }

    /**
     * @dev Deletes a product given the product ID.
     * @param _productId ID of the product to be deleted.
     * emit event ProductRemoved
     */

    function removeProduct(uint256 _productId) public {
        require(
            _productId > 0 && _productId <= productCounter,
            "Invalid product ID"
        );
        delete products[_productId - 1];
        emit ProductRemoved(_productId, msg.sender, block.timestamp);
    }

    function _getProduct(
        Product[] memory _arr,
        uint _productId
    ) public pure returns (Product memory) {
        for (uint i = 0; i < _arr.length; i++) {
            if (_arr[i].productId == _productId) {
                return _arr[i];
            }
        }
        revert("Product not found");
    }
}
