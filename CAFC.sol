// SPDX-License-Identifier: GPL-3.0

// Amended by Mr Black
/**
    !Disclaimer!
    These contracts is created by Mr Black of THE OBSIDIAN LLC.
*/

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  string public notRevealedUri;
  uint256 public cost = 0.02 ether;
  uint256 public maxSupply = 3000;
  uint256 public maxMintAmount = 6;
  uint256 public nftPerAddressLimit = 3;
  uint256 public nftPerEarlyPublicMintLimit = 2;
  bool public paused = true;
  bool public revealed = false;
  bool public dynamicCost = true;
  bool public onlyWhitelisted = true;
  bool public onlyEarlyPublicMint = false;
  address[] public whitelistedAddresses;
  address[] public earlyPublicMintAddresses;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function needToUpdateCost(uint256 supply) internal view returns (uint256 _cost){
      if(supply < 1000) {
          return 0.02 ether;
      }
      if(supply < 2000) {
          return 0.035 ether;
      }
      if(supply <= maxSupply) {
          return 0.04 ether;
      }
  }

  // public
  function mint(uint256 _mintAmount) public payable {
    require(!paused);
    uint256 supply = totalSupply();
    require(_mintAmount > 0);
    require(_mintAmount <= maxMintAmount);
    require(supply + _mintAmount <= 2700);

    if (msg.sender != owner()) {
     
        if(onlyWhitelisted == true) {
            require(isWhitelisted(msg.sender), "Sorry you are not Whitelisted");
            uint256 ownerTokenCount = balanceOf(msg.sender);
            require(ownerTokenCount < nftPerAddressLimit);
        }
          require(msg.value >= needToUpdateCost(supply) * _mintAmount, "Not enough funds to complete this purchase");

        if(onlyEarlyPublicMint == true) {
            require(isEarlyPublicMint(msg.sender), "Sorry you are not Early Public Mint List");
            uint256 ownerTokenCount = balanceOf(msg.sender);
            require(ownerTokenCount < nftPerEarlyPublicMintLimit);
        }
          require(msg.value >= needToUpdateCost(supply) * _mintAmount, "Not enough funds to complete this purchase");
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }

  function isWhitelisted(address _user) public view returns (bool){
      for(uint256 i = 0; i< whitelistedAddresses. length; i++){
          if (whitelistedAddresses[i] == _user) {
              return true;
          }
      }
      return false;

  }

  function isEarlyPublicMint(address _user) public view returns (bool){
      for(uint256 i = 0; i< earlyPublicMintAddresses. length; i++){
          if (earlyPublicMintAddresses[i] == _user) {
              return true;
          }
      }
      return false;

  }

  function mintForOwner(uint256 _mintAmount) public onlyOwner {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 0);
    require(_mintAmount <= maxMintAmount);
    require(supply + _mintAmount <= maxSupply);

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
  function reveal() public onlyOwner {
      revealed = true;
  }
  
  function setnftPerAddressLimit(uint256 _limit) public onlyOwner {
    nftPerAddressLimit = _limit;
  }
  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

  function setOnlyWhitelisted(bool _state) public onlyOwner {
    onlyWhitelisted = _state;
  }
 
 function whitelistUser(address[] calldata _user) public onlyOwner {
     delete whitelistedAddresses;
    whitelistedAddresses = _user;
  }
 

  function withdraw() public payable onlyOwner {
    // This will pay Mr Black 30% of the initial sale.
    // You can remove this if you want, or keep it in to support HashLips and his channel.
    // =============================================================================
    (bool hs, ) = payable(0x943590A42C27D08e3744202c4Ae5eD55c2dE240D).call{value: address(this).balance * 30 / 100}("");
    require(hs);
    // =============================================================================
    
    // This will payout the owner 70% of the contract balance.
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
    // =============================================================================
  }
}
