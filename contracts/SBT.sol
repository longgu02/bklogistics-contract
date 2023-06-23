// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BKLogisticsSBT is ERC721URIStorage {
    address owner;

    event Claim(uint tokenId, address account, uint timestamp);
    event Issue(address to, uint timestamp);

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
        emit Issue(to, block.timestamp);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(
            false && from == _msgSender() && to == _msgSender() && tokenId == 0,
            "Soulbound Token: Can't be transfered"
        );
    }

    // function safeTransferFrom(
    //     address from,
    //     address to,
    //     uint256 tokenId
    // ) public virtual override(ERC721, IERC721) {
    //     require(false, "Soulbound Token: Can't be transfered");
    // }

    // function safeTransferFrom(
    //     address from,
    //     address to,
    //     uint256 tokenId,
    //     bytes memory data
    // ) public virtual override(ERC721, IERC721) {
    //     require(false, "Soulbound Token: Can't be transfered");
    // }

    function claimSBT(string memory tokenURI) public returns (uint256) {
        require(issued[msg.sender], "SBT is not issued");
        counter++;
        uint newItemId = counter;
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        issued[msg.sender] = false;
        emit Claim(newItemId, msg.sender, block.timestamp);
        return newItemId;
    }

    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        _burn(tokenId);
    }
}
