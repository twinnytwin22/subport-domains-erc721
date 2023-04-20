// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {StringUtils} from "./libraries/StringUtils.sol";
// We import another help function
import {Base64} from "./libraries/Base64.sol";

import "hardhat/console.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract Domains is ERC721URIStorage {
  // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string public tld;
  
  // We'll be storing our NFT images on chain as SVGs
  string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="#fff"><path fill="url(#a)" d="M0 0h270v270H0z"/><defs><filter id="b" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path class="cls-2" d="M36.88 16.16h1.29c.05.02.09.04.14.05 1.24.11 2.4.49 3.48 1.12 3.61 2.11 7.23 4.21 10.83 6.34 2.13 1.26 3.44 3.14 3.98 5.55.09.41.14.82.2 1.24v3.46c-.01.07-.04.14-.04.22-.02 3.12-.01 6.24-.06 9.36-.05 3.21-1.48 5.69-4.23 7.32-3.6 2.12-7.24 4.15-10.87 6.21-.88.5-1.82.84-2.82 1l-1.06.15H37s-.09-.04-.14-.04c-1.11-.06-2.18-.31-3.17-.83-1.1-.58-2.17-1.22-3.24-1.85-2.77-1.62-5.57-3.2-8.31-4.88-2.51-1.54-3.89-3.85-4.02-6.78-.1-2.41 0-4.83 0-7.24 0-1.87 0-3.75.03-5.62.06-3.29 1.5-5.81 4.34-7.47 3.55-2.07 7.14-4.08 10.71-6.12.76-.43 1.56-.76 2.41-.95.42-.09.84-.15 1.26-.22ZM23.1 37.13h-.04v.49c0 1.89-.02 3.78-.01 5.67 0 1.36.61 2.39 1.76 3.1.58.36 1.17.69 1.76 1.03 2.98 1.74 5.96 3.49 8.94 5.23 1.16.68 2.36.75 3.53.1 3.67-2.06 7.32-4.15 10.97-6.25 1.13-.65 1.71-1.69 1.74-3 .03-1.28.03-2.56.04-3.84.01-2.88.03-5.76.03-8.64 0-1.37-.6-2.42-1.77-3.12-3.57-2.1-7.14-4.19-10.72-6.27-1.21-.7-2.44-.69-3.65 0-3.56 2.02-7.12 4.05-10.68 6.08-1.25.71-1.89 1.8-1.89 3.23-.01 2.06 0 4.13 0 6.19Z m13.74 2.7v-.67c0-1.75 0-3.51-.02-5.26-.03-3.02-.06-6.03-.1-9.05 0-.64.32-.99.97-1 .38 0 .76-.01 1.13 0 .45 0 .83.27.95.7.32 1.19 1.06 2.1 1.95 2.92.89.82 1.79 1.63 2.63 2.5 1.31 1.36 1.98 3 2.04 4.9.06 2.01-.51 3.84-1.59 5.51-.4.63-.98 1.14-1.48 1.72-.29-.2-.57-.38-.82-.58-.06-.04-.07-.18-.06-.26.14-.64.35-1.28.45-1.93.29-1.98.23-3.93-.74-5.75-.49-.91-1.17-1.61-2.18-1.94-.04-.01-.08-.02-.13-.04v1.63c.03 1.56.08 3.13.1 4.69.02 1.46-.02 2.92 0 4.38.03 1.61-.59 2.92-1.82 3.92-2.12 1.72-4.51 2.2-7.14 1.52-.73-.19-1.36-.57-1.87-1.13-.74-.8-.92-1.72-.6-2.75.39-1.24 1.2-2.14 2.28-2.83 1.8-1.15 3.76-1.54 5.87-1.2h.19Z"/><defs><linearGradient id="a" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#282828"/><stop offset="1" stop-opacity=".99"/></linearGradient></defs><text x="32.5" y="231" font-size="25" filter="url(#b)" font-family="syne,Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
  string svgPartTwo = '</text></svg>';

  mapping(string => address) public domains;
  mapping(string => string) public records;
  mapping (uint => string) public names;
  

// Add this anywhere in your contract body
function getAllNames() public view returns (string[] memory) {
  console.log("Getting all names from contract");
  string[] memory allNames = new string[](_tokenIds.current());
  for (uint i = 0; i < _tokenIds.current(); i++) {
    allNames[i] = names[i];
    console.log("Name for token %d is %s", i, allNames[i]);
  }

  return allNames;
}

  address payable public owner;

  constructor(string memory _tld) payable ERC721("Subport", "SBPRT") {
    tld = _tld;
    console.log("%s name service deployed", _tld);
  }
		
  // This function will give us the price of a domain based on length
  function price(string calldata name) public pure returns(uint) {
    uint len = StringUtils.strlen(name);
    require(len > 0);
    if (len == 3) {
      return 5 * 10**1; // 5 MATIC = 5 000 000 000 000 000 000 (18 decimals). We're going with 0.5 Matic cause the faucets don't give a lot
    } else if (len == 4) {
      return 3 * 10**1; // To charge smaller amounts, reduce the decimals. This is 0.3
    } else {
      return 1 * 10**1;
    }
  }
function setRecord(string calldata name, string calldata record) public {
  if (msg.sender != domains[name]) revert Unauthorized();
  records[name] = record;
}

function register(string calldata name) public payable {
  if (domains[name] != address(0)) revert AlreadyRegistered();
  if (!valid(name)) revert InvalidName(name);
  // Rest of register function remains unchanged

  uint256 _price = price(name);
  require(msg.value >= _price, "Not enough Matic paid");
  
  string memory _name = string(abi.encodePacked(name, ".", tld));
  string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));
  uint256 newRecordId = _tokenIds.current();
  uint256 length = StringUtils.strlen(name);
  string memory strLen = Strings.toString(length);

  console.log("Registering %s on the contract with tokenID %d", name, newRecordId);

  string memory json = Base64.encode(
    abi.encodePacked(
        '{"name": "',
        _name,
        '", "description": "A domain on the Performer Registry name service", "image": "data:image/svg+xml;base64,',
        Base64.encode(bytes(finalSvg)),
        '","length":"',
        strLen,
        '"}'
    )
  );

  string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));
    
  console.log("\n--------------------------------------------------------");
  console.log("Final tokenURI", finalTokenUri);
  console.log("--------------------------------------------------------\n");

  _safeMint(msg.sender, newRecordId);
  _setTokenURI(newRecordId, "ipfs://QmWcECd1rtuqDrkwWdeeorVVG16ZQGaoq2W2gdEPm9EkBg");

  
  domains[name] = msg.sender;
  
  names[newRecordId] = name;

  _tokenIds.increment();
}
  // Other functions unchanged

  function getAddress(string calldata name) public view returns (address) {
      // Check that the owner is the transaction sender
      return domains[name];
  }

  function getRecord(string calldata name) public view returns(string memory) {
      return records[name];
  }
  
  modifier onlyOwner() {
  require(isOwner());
  _;
}

function isOwner() public view returns (bool) {
  return msg.sender == owner;
}

function valid(string calldata name) public pure returns(bool) {
  return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 18;
}

  function burn(uint tokenId) public {
        require(msg.sender == owner, "Only the owner can burn tokens");
        // Check that the token with the specified ID exists
        require(_exists(tokenId), "Token does not exist");
        // Perform any additional checks or actions before burning the token
        // ...
        _burn(tokenId);
    }


function withdraw() public onlyOwner {
  uint amount = address(this).balance;
  
  (bool success, ) = msg.sender.call{value: amount}("");
  require(success, "Failed to withdraw Matic");
  } 

error Unauthorized();
error AlreadyRegistered();
error InvalidName(string name);

}
