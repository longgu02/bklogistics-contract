// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Products {
    enum ProductType {
        MATERIAL,
        PRODUCT
    }

    enum Unit {
        NONE,
        KILOGRAM,
        METER,
        LITRE
    }

    struct Product {
        uint256 productId; // Product unique identifier
        string name; // Product name
    }

    struct Material {
        uint256 materialId; // Material unique identifier
        string name; // Material name
    }

    struct RequiredMaterial {
        uint[] requiredMaterial;
        mapping(uint => uint) requiredQuantity;
        mapping(uint => Unit) unit;
    }

    struct MaterialPair {
        uint materialId;
        uint quantity;
        Unit unit;
    }

    mapping(uint => Product) products; // Mapping of product ID to product details
    uint256 public productCounter; // Counter for total number of products added to the system
    mapping(uint => Material) materials; // Mapping of product ID to material details
    uint256 public materialCounter; // Counter for total number of material added to the system
    mapping(uint => RequiredMaterial) requiredMaterials;

    event ProductAdded(
        uint256 productId,
        string name,
        address adder,
        uint256 addedDate
    );

    event MaterialAdded(
        uint256 materialId,
        string name,
        address adder,
        uint256 addedDate
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

    function addProduct(string memory _name) public returns (uint productId) {
        // Check if product with the same name already exists
        for (uint i = 0; i < productCounter; i++) {
            if (keccak256(bytes(products[i].name)) == keccak256(bytes(_name))) {
                revert("Product with same name already exists");
            }
        }

        // Add new product
        Product memory newProduct = Product({
            productId: productCounter + 1,
            name: _name
        });
        products[productCounter] = newProduct;
        productCounter++;
        emit ProductAdded(
            newProduct.productId,
            _name,
            msg.sender,
            block.timestamp
        );
        return newProduct.productId;
    }

    function addRequiredMaterial(
        uint _productId,
        uint _materialId,
        uint _quantity,
        Unit _unit
    ) public {
        requiredMaterials[_productId].requiredMaterial.push(_materialId);
        requiredMaterials[_productId].requiredQuantity[_materialId] = _quantity;
        requiredMaterials[_productId].unit[_materialId] = _unit;
    }

    function addMaterial(string memory _name) public returns (uint materialId) {
        // Check if product with the same name already exists
        for (uint i = 0; i < productCounter; i++) {
            if (keccak256(bytes(products[i].name)) == keccak256(bytes(_name))) {
                revert("Material with same name already exists");
            }
        }

        // Add new product
        Material memory newMaterial = Material({
            materialId: materialCounter + 1,
            name: _name
        });
        materials[materialCounter] = newMaterial;
        materialCounter++;
        emit ProductAdded(
            newMaterial.materialId,
            _name,
            msg.sender,
            block.timestamp
        );
        return newMaterial.materialId;
    }

    /**
     * @dev Gets the details of a product given the product ID.
     * @param _productId ID of the product to be retrieved.
     * @return productId details of the product with the given ID.
     * @return name details of the product with the given ID.
     */

    function getProduct(
        uint256 _productId
    ) public view returns (uint productId, string memory name) {
        require(
            _productId > 0 && _productId <= productCounter,
            "Invalid product ID"
        );
        return (_productId, products[_productId - 1].name);
    }

    function getMaterial(
        uint256 _materialId
    ) public view returns (uint productId, string memory name) {
        require(
            _materialId > 0 && _materialId <= materialCounter,
            "Invalid material ID"
        );
        return (_materialId, materials[_materialId - 1].name);
    }

    function getRequiredMaterial(
        uint256 _productId
    ) public view returns (MaterialPair[] memory) {
        require(
            _productId > 0 && _productId <= productCounter,
            "Invalid product ID"
        );
        uint[] memory materialList = requiredMaterials[_productId]
            .requiredMaterial;
        MaterialPair[] memory result = new MaterialPair[](materialList.length);
        for (uint i = 0; i < materialList.length; i++) {
            result[i] = MaterialPair({
                materialId: materialList[i],
                quantity: requiredMaterials[_productId].requiredQuantity[
                    materialList[i]
                ],
                unit: requiredMaterials[_productId].unit[materialList[i]]
            });
        }
        return result;
    }

    function updateMaterial(uint256 _materialId, string memory _name) public {
        require(
            _materialId > 0 && _materialId <= productCounter,
            "Invalid product ID"
        );
        Material storage material = materials[_materialId - 1];
        material.name = _name;
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
}
