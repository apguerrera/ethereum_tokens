/******************************************************************************\

file:   Forwarder.sol
ver:    0.4.1
updated:13-Nov-2017
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

This file is part of the SandalStraps framework

PassPurse creates password permissioned single use wallets from
which ether is swept to a calling address if the correct password
is provided or to the creator if the wallet has expired.

*** WARNING *** This is concept code only. It is vulnerable to 
front running and miner attacks upon the password at time of claim

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

Release Notes
-------------

\******************************************************************************/

pragma solidity ^0.4.13;

import "https://github.com/o0ragman0o/SandalStraps/contracts/Registrar.sol";
import "https://github.com/o0ragman0o/Withdrawable/contracts/Withdrawable.sol";

contract PassPurse
{
    bytes27 passHash;
    uint40 public expiry;
    address public owner;
    
    event Deposit(address indexed _from, uint _value);
    
    function PassPurse(bytes32 _passHash, uint _expiry)
        public
        payable
    {
        passHash = bytes27(_passHash);
        expiry = uint40(_expiry);
        owner = msg.sender;
        if (msg.value > 0) {
            Deposit(msg.sender, msg.value);
        }
    }
    
    function ()
        public
        payable
    {
        if (msg.value > 0) {
            Deposit(msg.sender, msg.value);
        }
    }
    
// TODO: Prone to front running. Try requiring a fixed gas price
// or 2 tx claim and prove model
    function sweep(bytes32 _pass)
        public
    {
        address recip = now > expiry ? owner :
            bytes27(keccak256(_pass)) == passHash ? msg.sender :
            0x0;
        if (recip != 0x0) selfdestruct(recip);
    }
}


contract PassPurses is RegBase, Withdrawable
{
//
// Constants
//

    /// @return The contract's version constant
    bytes32 constant public VERSION = "PassPurse v0.4.0";

    /// @dev 0.2% commission to creator
    uint constant COMMISSION_DIV = 500;

//
// State
//

    /// @return The commision wallet address
    address public commissionWallet;

    /// @return The forwarding address.
    address[] public purses;
    
//
// Events
//
    
    /// @dev Logged upon forwarding a transaction
    /// @param _kAddr The purse address
    /// @param _pass The hash of the password
    event NewPurse(address indexed _kAddr, bytes27 _pass);

//
// Functions
//

    /// @dev A SandalStraps compliant constructor
    /// @param _creator The creating address
    /// @param _regName The contracts registration name
    /// @param _owner The owner address for the contract
    function PassPurses(address _creator, bytes32 _regName, address _owner)
        public
        RegBase(_creator, _regName, _owner)
    {
        commissionWallet = _creator;
    }
    
    /// @dev Transactions are unconditionally forwarded to the forwarding address
    function ()
        public
        payable 
    {
        if(msg.value > 0) {
            Deposit(msg.sender, msg.value);
        }
    }

    /// @notice Create a PassPurse which expires after `_expiry`
    /// @param _pass The hash of a password
    /// @param _expiry An epoch time for expiry
    /// @param kAddr_ The created purse address
    function createNew(bytes27 _pass, uint _expiry)
        public
        payable
        returns (address kAddr_)
    {
        Deposit(msg.sender, msg.value);
        kAddr_ = address(new PassPurse(_pass, _expiry));
        purses.push(kAddr_);
        NewPurse(kAddr_, _pass);
        Withdrawal(this, kAddr_, msg.value - msg.value / COMMISSION_DIV);
        Withdrawal(commissionWallet, commissionWallet, msg.value / COMMISSION_DIV);
        commisionWallet.transfer(msg.value / COMMISSION_DIV)
    }
    
    /// @dev For recovering expired purse funds
    function withdrawAll()
        public
        returns (bool)
    {
        Withdrawal(owner, owner, this.balance);
        owner.transfer(this.balance);
    }
}


contract PassPursesFactory is Factory
{
//
// Constants
//

    /// @return registrar name
    bytes32 constant public regName = "passpurses";
    
    /// @return version string
    bytes32 constant public VERSION = "PassPursesFactory v0.4.0";

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
    function PassPursesFactory(
        address _creator, bytes32 _regName, address _owner)
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
        returns (address kAddr_)
    {
        kAddr_ = address(new PassPurses(msg.sender, _regName, _owner));
        Created(msg.sender, _regName, kAddr_);
    }
}

