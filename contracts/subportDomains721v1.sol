// SPDX-License-Identifier: MIT
/*
/Author Randal Herndon | Twinny
* Created: April 22nd, 2023
* subport.xyz
                  __                             __   
 .-----. .--.--. |  |--. .-----. .-----. .----. |  |_ 
 |__ --| |  |  | |  _  | |  _  | |  _  | |   _| |   _|
 |_____| |_____| |_____| |   __| |_____| |__|   |____|
                         |__|                                    
*/
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "./access/Pausable.sol";
import {Base64} from "./libraries/Base64.sol";

contract SubportDomains721v1 is ERC721URIStorageUpgradeable, Pausable, StringsUpgradeable{
    using StringsUpgradeable for uint256;
    

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIds;

    address private _owner;
    string public tld;
    bool public openToPublic;
    bool public isBeta;

    //@dev On-chain storage of the svg
    string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" viewBox="0 0 270 270" fill="none"><path fill="url(#a)" d="M0 0h270v270H0z"/><defs><filter id="b" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path d="M16.29 59.69a11.06 11.06 0 0 1 10.83-8.79h19.72c2.14 0 3.29-1.15 3.59-2.56.33-1.57-.49-2.39-2.63-2.39H34.85c-9.4 0-15.58-4.78-13.28-15.75 2.42-11.55 12.8-15.84 20.8-15.84h18.35c5.93 0 10.36 5.46 9.15 11.26a2.653 2.653 0 0 1-2.59 2.1H42.21c-2.06 0-3.11 1.07-3.39 2.39s.31 2.47 2.37 2.47h11.05c11.88 0 17.44 6.1 15.49 15.42s-10.5 16.25-21.88 16.25H20c-2.41 0-4.21-2.21-3.71-4.57Z" fill="#fff"/><defs><linearGradient id="a" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#00008b"/><stop offset="1" stop-color="#004eba" stop-opacity=".99"/></linearGradient></defs><text x="20.5" y="231" font-size="18" fill="#fff" filter="url(#b)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartTwo = "</text></svg>";

    mapping(string => address) public domains;
    mapping(string => string) public records;
    mapping(string => string) public roles;
    mapping(uint => string) public names;



    ///constructor(string memory _tld) payable ERC721("subport", "SBPRT") {
    ///tld = _tld;
    ///isBeta = true;
    ///openToPublic = true;
    ///}
    function initialize() initializer public {
        __ERC721_init('subport', "SBPRT");
    }
        //@dev Check that the name and/or role is valid.
    modifier nameArgsOK(string calldata name, string calldata role) {
        require(valid(name), string(abi.encodePacked("InvalidName: ", name)));
        require(domains[name] == address(0), "AlreadyRegistered");
        require(
            keccak256(bytes(role)) == keccak256(bytes("creator")) ||
                keccak256(bytes(role)) == keccak256(bytes("admin")) ||
                keccak256(bytes(role)) == keccak256(bytes("collector")),
            "Invalid role"
        );
        require(
            keccak256(bytes(role)) != keccak256(bytes("admin")) ||
                msg.sender == owner(),
            "Admin role can only be assigned by owner"
        );
     _;
    }

    // Add this anywhere in your contract body
    function getAllNames() public view returns (string[] memory) {
        string[] memory allNames = new string[](_tokenIds.current());
        for (uint i = 0; i < _tokenIds.current(); i++) {
            allNames[i] = string(abi.encodePacked(names[i]));
        }
        return allNames;
    }

    // This function will give us the price of a domain based on length
    function price(string calldata name) public view returns (uint) {
        uint256 len = bytes(name).length;
        require(len > 0);
        if (isBeta) {
            return 0;
        } else if (len <= 5) {
            return 25 * 10 ** 18; //25 matic for premium domain names once beta is over
        } else if (len == 4) {
            return 20 * 10 ** 18; //20
        } else {
            return 15 * 10 ** 18; //15
        }
    }

    //@dev Token Logic
function getTokenJson(
        string memory name,
        string memory role,
        string memory finalSvg
    ) internal view returns (string memory) {
        uint256 length = bytes(name).length;
        string memory strLen = StringsUpgradeable.toString(length);
        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                name,
                ".",
                tld,
                '","description": "your official subport handle","image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(finalSvg)),
                '","length": "',
                strLen,
                '","role": "',
                role,
                '"}'
            )
        );

        return json;
    }

    //@dev Private domain creation, only owners can reserve - essential for special @handles
    function reserve(
        string calldata name,
        string calldata role
    ) public payable isSubport nameArgsOK(name, role) {
        string memory _name = string(abi.encodePacked(name, ".", tld));
        string memory finalSvg = string(
            abi.encodePacked(svgPartOne, _name, svgPartTwo)
        );
        uint256 newRecordId = _tokenIds.current();
        string memory finalTokenUri = string(
            abi.encodePacked(
                "data:application/json;base64,",
                getTokenJson(name, role, finalSvg)
            )
        );
        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri);
        names[newRecordId] = name;
        domains[name] = msg.sender;
        _tokenIds.increment();
    }

    //@dev Public domain creation
    function register(
        string calldata name,
        string calldata role
    ) public payable nameArgsOK(name, role) {
        require(openToPublic, "Unauthorized");
        require(
            balanceOf(msg.sender) < 1,
            "Ayeeoo: You can only mint one free collectible!"
        );
        uint256 _price = price(name);
        require(msg.value >= _price, "Not enough Matic paid");
        string memory _name = string(abi.encodePacked(name, ".", tld));
        string memory finalSvg = string(
            abi.encodePacked(svgPartOne, _name, svgPartTwo)
        );
        string memory finalTokenUri = string(
            abi.encodePacked(
                "data:application/json;base64,",
                getTokenJson(name, role, finalSvg)
            )
        );

        uint256 newRecordId = _tokenIds.current();

        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri);
        domains[name] = msg.sender;
        names[newRecordId] = name;

        _tokenIds.increment();
    }

    function getAddress(string calldata name) public view returns (address) {
        // Check that the owner is the transaction sender
        return domains[name];
    }

    function getRole(string calldata name) public view returns (string memory) {
        return roles[name];
    }

   
    //@dev Check name length to ensure it falls within agreement
    function valid(string calldata name) public pure returns (bool) {
        bytes memory nameBytes = bytes(name);
        uint256 nameLength = nameBytes.length;
        return nameLength >= 3 && nameLength <= 18;
    }

    //@dev Reserve the right to burn tokens that fall outside of agreements
    function burn(uint tokenId) public isSubport {
        require(_exists(tokenId), "Token does not exist");
        _burn(tokenId);
    }

    //@dev Beta Phase has no pricing model.
    function togglePhase() public isSubport {
        isBeta = !isBeta;
    }
     //@dev Beta Phase has no pricing model.
    function toggleSale() public isSubport {
        openToPublic = !openToPublic;
    }

    //@dev Determine if an address is a smart contract
    function _isContract(address a) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(a)
        }
        return size > 0;
    }

    //@dev Withdraw
    function withdraw() public isSubport {
        uint amount = address(this).balance;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw Matic");
    }
}
