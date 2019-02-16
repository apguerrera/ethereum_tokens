/******************************************************************************\
file:   DepositWithdrawAll.sol
ver:    0.4.3
updated:3-Sep-2017
author: Darryl Morris
email:  o0ragman0o AT gmail.com

A SandalStraps compliant Deposit and WithdrawAll forwarding payment channel.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

    
Release notes
-------------
* using solidity 0.4.24 syntax
\******************************************************************************/

pragma solidity ^0.4.24;

import "https://github.com/o0ragman0o/SandalStraps/contracts/Factory.sol";
import "https://github.com/o0ragman0o/Withdrawable/contracts/Withdrawable.sol";

contract DepositWithdrawAll is RegBase, WithdrawableMinAbstract
{
//
// Constants
//

    /// @return The version constant
    bytes32 constant public VERSION = "DepositWithdrawAll v0.4.3";

//
// State
//

    /// @return The forwarding address
    address public forwardTo;
    
//
// Events
//

    // Logged upon change of the forwardTo address
    /// @param _to Address to which withdrawls are sent
    event ForwardingTo(address indexed _to);

//
// Functions
//

	/// @dev Sandalstraps complaint constructor
    constructor(address _creator, bytes32 _regName, address _owner)
        public
        RegBase(_creator, _regName, _owner)
    {
        // forwardTo will be set to msg.sender of if _owner == 0x0 or _owner
        // otherwise
        forwardTo = owner;
        emit ForwardingTo(forwardTo);
    }
    
    /// @dev Default function is payable
    function ()
        public
        payable 
    {
        emit Deposit(msg.sender, msg.value);
    }
    
    // @notice Change the fording address to `_forwardTo`
    // @param _forwardTo An address which will receive withdrawls
    // @return Boolean success value
    function changeForwardTo(address _forwardTo)
        public
        returns (bool)
    {
        // Only owner or current forwarding address can change the
        // forwarding address 
        require(msg.sender == owner || msg.sender == forwardTo);
        forwardTo = _forwardTo;
        emit ForwardingTo(_forwardTo);
        return true;
    }

    /// @notice withdraw total balance to forwardTo address
    /// @return success
    function withdrawAll()
    	public
    	returns (bool)
    {
    	emit Withdrawal(forwardTo, forwardTo, address(this).balance);
    	forwardTo.transfer(address(this).balance);
    	return true;
    }
}


contract DepositWithdrawAllFactory is Factory
{
//
// Constants
//

    bytes32 constant public regName = "depositwithdrawall";
    bytes32 constant public VERSION = "DepositWithdrawAllFactory v0.4.3";

//
// Functions
//

    /// @param _creator The calling address passed through by a factory,
    /// typically msg.sender
    /// @param _regName A static name referenced by a Registrar
    /// @param _owner optional owner address if creator is not the intended
    /// owner
    /// @dev On 0x0 value for _owner or _creator, ownership precedence is:
    /// `_owner` else `_creator` else msg.sender
    constructor(address _creator, bytes32 _regName, address _owner)
        public
        Factory(_creator, regName, _owner)
    {
        _regName; // Not passed to super. quite compiler warning
    }

    /// @notice Create a new product contract
    /// @param _regName A unique name if the the product is to be registered in
    /// a SandalStraps registrar
    /// @param _owner An address of a third party owner.  Will default to
    /// msg.sender if 0x0
    /// @return kAddr_ The address of the new product contract
    function createNew(bytes32 _regName, address _owner)
        public
        payable
        pricePaid
        returns(address kAddr_)
    {
        require(_regName != 0x0);
        _owner = _owner == 0x0 ? msg.sender : _owner;
        kAddr_ = address(new DepositWithdrawAll(this, _regName, _owner));
        emit Created(msg.sender, _regName, kAddr_);
    }
}