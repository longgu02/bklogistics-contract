// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract BKLogisticsSBT is ERC721URIStorage {
    address owner;

    constructor() ERC721("BKLogisticsSBT", "BKLSBT") {
        owner = msg.sender;
    }

    uint256 counter = 0;

    mapping(address => bool) public issued;

    modifier onlyOwner() {
        require(msg.sender == owner, "Permission denied!");
        _;
    }

    function issue(address to) external onlyOwner {
        issued[to] = true;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        require(false, "Soulbound Token: Can't be transfered");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override(ERC721, IERC721) {
        require(false, "Soulbound Token: Can't be transfered");
    }

    function claimSBT(string memory tokenURI) public returns (uint256) {
        require(issued[msg.sender], "SBT is not issued");
        counter++;
        uint newItemId = counter;
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        issued[msg.sender] = false;
        return newItemId;
    }
}
