// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "hardhat/console.sol";

contract NFTMarketPlace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private itemSold;
    
    address payable owner;
    uint256 listingPrice = 0.0015 ether;

    mapping(uint256 => MarketItem) private idMarketItem;

    struct MarketItem {
        uint tokenID;
        address payable seller;
        address payable owner;
        uint price;
        bool sold;
    }

    event IdMarketItemCreated(uint indexed tokenId, address seller, address owner, uint256 price, bool sold);

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can change the listing price");
        _;
    }

    constructor() ERC721("Metaverse", "MTV") {
        owner = payable(msg.sender);
    }

    function updateListingPrice(uint256 _listingPrice) public onlyOwner {
        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    // Creating NFT Token Function
    function createToken(string memory tokenURI, uint256 price) public payable returns (uint256) {
        require(msg.value == listingPrice, "Must pay listing price to mint");

        _tokenIds.increment();
        uint256 newTokenID = _tokenIds.current();

        _mint(msg.sender, newTokenID);
        _setTokenURI(newTokenID, tokenURI);

        createMarketItem(newTokenID, price);

        return newTokenID;
    }

    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be greater than zero");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        _transfer(msg.sender, address(this), tokenId);

        emit IdMarketItemCreated(tokenId, msg.sender, address(this), price, false);
    }

    // Function to resell token
    function resellToken(uint256 tokenId, uint256 price) public payable {
        require(idMarketItem[tokenId].seller == msg.sender, "Only the seller can perform this function");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        idMarketItem[tokenId].sold = false;
        idMarketItem[tokenId].price = price;
        idMarketItem[tokenId].seller = payable(msg.sender);
        idMarketItem[tokenId].owner = payable(address(this));

        _transfer(msg.sender, address(this), tokenId);

        emit IdMarketItemCreated(tokenId, msg.sender, address(this), price, false);
    }

    //function createMarketPlace

    function createMarketPlace(uint256 tokenId) public payable {
      uint256 price = idMarketItem[tokenId].price;

      require(msg.value == price, "Please submit the asking price in order to complete purchase");

      idMarketItem[tokenId].owner = payable(msg.sender);
      idMarketItem[tokenId].sold = true;
      idMarketItem[tokenId].owner = payable(address(0));

      itemSold.increment();

      _transfer(address(this), msg.sender, tokenId);

      payable(owner).transfer(listingPrice);
      payable(idMarketItem[tokenId].seller).transfer(msg.value);
    }

    //getting unsold nft data
}
