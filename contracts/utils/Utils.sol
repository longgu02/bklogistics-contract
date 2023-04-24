// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "../Product.sol";

contract Utils is Products{

  function isIncludeAddress(address[] memory _arr, address _address) pure public returns (bool) {
    for(uint i = 0; i < _arr.length; i++){
      if(_arr[i] == _address) return true;
    }
    return false;
  }

  function isStakeHolder(address[] memory _suppliers, address[] memory _manufacturers, address _customer, address _sender) pure public returns (bool){
    if(_sender == _customer){
      return true;
    }else if(isIncludeAddress(_manufacturers, _sender)){
      return true;
    }else if(isIncludeAddress(_suppliers, _sender)){
      return true;
    }else {
      return false;
    }
  }

  function getProduct(Product[] memory _arr ,uint _productId) pure public returns(Product memory){
    for(uint i = 0; i < _arr.length; i++){
      if(_arr[i].productId == _productId) {
        return _arr[i];
      }
    }
    revert("Product not found");
  }
}