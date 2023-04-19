// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Products {
  struct Product {
    uint productId;
    string productName;
    uint addedDate;

  }

  Product[] productList;

  function addProduct(string memory _productName) public {
    Product memory newProduct = Product({
      productId: productList.length,
      productName: _productName,
      addedDate: block.timestamp
    });
    productList.push(newProduct);
  }

  // function removeProduct(uint _productId) public {
  //   productId 
  // }

  // function getProduct(uint _productId) public {

  // }
}
