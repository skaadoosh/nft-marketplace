// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 1. 'listitem': list nft on marketplace
// 2. 'buyitem': buy the nft
// 3. 'cancelitem': cancel a listing
// 4. 'updateListing': update price
// 5. 'witdrawProceeds': witdraw payment for my bought nft

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NftMarketplace_priceMustBeAboveZero();
error NftMarketplace_NotApprovedForMarketplace();
error NftMarketplace_AlreadyListed(address nftAddress, uint256 tokenId);
error NftMarketplace_NotOwner();

contract NftMarketplace {
    struct Listing {
        uint256 price;
        address seller;
    }

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    mapping(address => mapping(uint256 => Listing)) private s_listings;

    /////////////////////
    //Modifiers     /////
    /////////////////////
    modifier notListed(
        address nftAddress,
        uint256 tokenId,
        address owner
    ) {
        Listing memory lisitng = s_listings[nftAddress][tokenId];
        if (lisitng.price > 0) {
            revert NftMarketplace_AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    modifier notOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NftMarketplace_NotOwner();
        }
        _;
    }

    /////////////////////
    //Methods     /////
    /////////////////////

    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        notListed(nftAddress, tokenId, msg.sender)
        notOwner(nftAddress, tokenId, msg.sender)
    {
        if (price <= 0) {
            revert NftMarketplace_priceMustBeAboveZero();
        }
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NftMarketplace_NotApprovedForMarketplace();
        }
        s_listings[nftAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    function buyItem(address nftAddress, uint256 tokenId) external payable {}
}
