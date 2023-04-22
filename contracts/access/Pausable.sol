// SPDX-License-Identifier: MIT
/*
 * Pausable.sol
 *
 * Created: October 3, 2022
 *
 * Provides functionality for pausing and unpausing the sale (or other functionality)
 */

pragma solidity >=0.5.16 <0.9.0;

import "./SubportOwnable.sol";

//@title Pausable
//@author Twinny @djtwinnytwin
contract Pausable is SubportOwnable {

	event Paused(address indexed a);
	event Unpaused(address indexed a);

	bool private _paused;

	constructor() {
		_paused = false;
	}

	modifier saleActive()
	{
		require(!_paused, "Pausable: sale paused.");
		_;
	}


	//@dev Pause or unpause minting
	function toggleSaleActive() public isSubport
	{
		_paused = !_paused;

		if (_paused) {
			emit Paused(_msgSender());
		} else {
			emit Unpaused(_msgSender());
		}
	}

	//@dev Determine if the sale is currently paused
	function paused() public view virtual returns (bool)
	{
		return _paused;
	}
}