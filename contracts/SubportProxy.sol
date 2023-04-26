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
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";




import {Base64} from "./libraries/Base64.sol";

contract SubportDomains721v1 is PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable, ERC721Upgradeable {
    using StringsUpgradeable for uint256;
    

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIds;




    ///constructor(string memory _tld) payable ERC721("subport", "SBPRT") {
    ///tld = _tld;
    ///isBeta = true;
    ///openToPublic = true;
    ///}
    function initialize() public initializer {
        __ERC721_init('subport', "SBPRT");
      __Ownable_init();
        __Pausable_init();
    }


    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
        function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override( ERC721Upgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
        //@dev Check that the name and/or role is valid.
  
}
