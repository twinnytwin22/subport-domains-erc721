// SPDX-License-Identifier: MIT
/*
 * SubportOwnable.sol
 
 */

pragma solidity >=0.5.16 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SubportOwnable is Ownable {

	//@dev Ownership - list of port members (owners)
	mapping (address => bool) internal _port;

	constructor() {
		//add port and then twinny then crib
		_port[0x690A0e1Eaf12C8e4734C81cf49d478A2c6473A73] = true;
		_port[0x567B5E79cE0d465a0FF1e1eeeFE65d180b4C5D41] = true;
		_port[0xb40C70c616c35F1dFA088c3B56d61BDbaBFf533E] = true;
	}

	//@dev Custom modifier for multiple owners
	modifier isSubport()
	{
		require(isInSubport(_msgSender()), "subport ownable: Caller not part of the port.");
		_;
	}

	//@dev Determine if address `a` is an approved owner
	function isInSubport(address a) public view returns (bool) 
	{
		return _port[a];
	}

	//@dev Add `a` to the port
	function addToPort(address a) public onlyOwner
	{
		require(!isInSubport(a), "subport ownable: Address already in the port.");
		_port[a] = true;
	}

	//@dev Remove `a` from the port
	function removeFromPort(address a) public onlyOwner
	{
		require(isInSubport(a), "subport ownable: Address already not in the port.");
		_port[a] = false;
	}
	

}