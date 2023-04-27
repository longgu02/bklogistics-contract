// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Role.sol";

contract Products is Roles {
    struct Product {
        uint256 productId;
        string name;
        uint256 price;
        uint256 quantity;
    }

    mapping(uint => Product) products;
    uint private productCounter;

    event ProductAdded(uint256 productId, string name, uint256 price, uint256 quantity);

    function addProduct(string memory _name, uint _price, uint _quantity) public {
        require(_price > 0, "Price must be greater than 0");
        require(_quantity > 0, "Quantity must be greater than 0");
        
        // Check if product with the same name already exists
        for (uint i = 0; i < productCounter; i++) {
            if (keccak256(bytes(products[i].name)) == keccak256(bytes(_name))) {
                revert("Product with same name already exists");
            }
        }
        
        // Add new product
        Product memory newProduct = Product(productCounter, _name, _price, _quantity);
        products[productCounter] = newProduct;
        productCounter++;
    }

    function getProduct(uint256 _productId) public view returns (Product memory) {
        require(_productId > 0 && _productId <= productCounter, "Invalid product ID");
        return products[_productId - 1];
    }

    function updateProduct(uint256 _productId, string memory _name, uint256 _price, uint256 _quantity) public {
        require(_productId > 0 && _productId <= productCounter, "Invalid product ID");
        Product storage product = products[_productId - 1];
        product.name = _name;
        product.price = _price;
        product.quantity = _quantity;
    }

    function removeProduct(uint256 _productId) public {
        require(_productId > 0 && _productId <= productCounter, "Invalid product ID");
        delete products[_productId - 1];
    }
}