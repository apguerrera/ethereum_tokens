/******************************************************************************\

file:   Forwarder.sol
ver:    0.4.3
updated:3-Sep-20018
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

This file is part of the SandalStraps framework

CallForwarder acts as a proxy address for call pass-through of call data, gas
and value.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

Release Notes
-------------
* Using Solidity 0.4.24 syntax
\******************************************************************************/

pragma solidity ^0.4.24;

import "https://github.com/o0ragman0o/SandalStraps/contracts/Factory.sol";

contract Forwarder is RegBase {
//
// Constants
//

    /// @return The contract's version constant
    bytes32 constant public VERSION = "Forwarder v0.4.3";

//
// State
//

    /// @return The forwarding address.
    address public forwardTo;
    
//
// Events
//
    
    /// @dev Logged upon forwarding a transaction
    /// @param _from The calling address
    /// @param _to The forwarding address
    /// @param _value The value of ether forwarded
    event Forwarded(
        address indexed _from,
        address indexed _to,
        uint _value);

//
// Functions
//

    /// @dev A SandalStraps compliant constructor
    /// @param _creator The creating address
    /// @param _regName The contracts registration name
    /// @param _owner The owner address for the contract
    constructor(address _creator, bytes32 _regName, address _owner)
        public
        RegBase(_creator, _regName, _owner)
    {
        // forwardTo will be set to msg.sender of if _owner == 0x0 or _owner
        // otherwise
        forwardTo = owner;
    }
    
    /// @dev Transactions are unconditionally forwarded to the forwarding address
    function ()
        public
        payable 
    {
        emit Forwarded(msg.sender, forwardTo, msg.value);
        require(forwardTo.call.value(msg.value)(msg.data));
    }

    /// @notice Change the fording address to `_forwardTo`
    /// @param _forwardTo A forwarding address
    /// @return Boolean success value
    function changeForwardTo(address _forwardTo)
        public
        returns (bool)
    {
        // Only owner or forwarding address can change forwarding address 
        require(msg.sender == owner || msg.sender == forwardTo);
        forwardTo = _forwardTo;
        return true;
    }
}


contract ForwarderFactory is Factory
{
//
// Constants
//

    /// @return registrar name
    bytes32 constant public regName = "forwarder";
    
    /// @return version string
    bytes32 constant public VERSION = "ForwarderFactory v0.4.3";

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
        // _regName is ignored as `regName` is already a constant
        _regName; // Not passed to super. Quiet compiler warning
        // nothing to construct
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
        returns (address kAddr_)
    {
        kAddr_ = address(new Forwarder(msg.sender, _regName, _owner));
        emit Created(msg.sender, _regName, kAddr_);
    }
}
