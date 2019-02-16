/******************************************************************************\

file:   PayableERC20.sol
ver:    0.4.4
updated:18-Sep-2017
author: Darryl Morris
email:  o0ragman0o AT gmail.com

A payable ERC20 token where payments are split according to token holdings.

WARNINGS:
* These tokens are not suitible for trade on a centralised exchange.
Doing so will result in permanent loss of ether.
* These tokens may not be suitable for state channel transfers as no ether
balances will be accounted for

The supply of this token is a constant of 100 tokens with 18 decimal places
which can intuitively represent 100% to be distributed to holders.


This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

Release notes
-------------
* Using Solidity 0.4.24 syntax
* Using SandalStraps 0.4.3
* Moved totalSupply into `_init()`
* added __initFuse
* removed `withdrawAllFrom()`. `Yank` should be used for pull along payments

\******************************************************************************/

pragma solidity ^0.4.24;

import "https://github.com/o0ragman0o/Math/Math.sol";
import "https://github.com/o0ragman0o/ReentryProtected/ReentryProtected.sol";
import "https://github.com/o0ragman0o/SandalStraps/contracts/Factory.sol";
import "https://github.com/o0ragman0o/Withdrawable/contracts/Withdrawable.sol";


// ERC20 Standard Token Abstract including state variables
contract ERC20Abstract
{
/* Structs */

/* State Valiables */

    /// @return
    uint public totalSupply;
    
    /// @return
    uint8 public decimals;
    
    /// @return Token symbol
    string public symbol;
    
    /// @return Token Name
    string public name;

/* Events */

    /// @dev Logged when tokens are transferred.
    /// @param _from The address tokens were transferred from
    /// @param _to The address tokens were transferred to
    /// @param _value The number of tokens transferred
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value);

    /// @dev Logged when approve(address _spender, uint256 _value) is called.
    /// @param _owner The owner address of spendable tokens
    /// @param _spender The permissioned spender address
    /// @param _value The number of tokens that can be spent
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value);

/* Modifiers */

/* Function Abstracts */

    /// @param _addr The address of a token holder
    /// @return The amount of tokens held by `_addr`
    function balanceOf(address _addr) public view returns (uint);

    /// @param _owner The address of a token holder
    /// @param _spender the address of a third-party
    /// @return The amount of tokens the `_spender` is allowed to transfer
    function allowance(address _owner, address _spender) public view
        returns (uint);
        
    /// @notice Send `_amount` of tokens from `msg.sender` to `_to`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to transfer
    function transfer(address _to, uint256 _amount) public returns (bool);

    /// @notice Send `_amount` of tokens from `_from` to `_to` on the condition
    /// it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to transfer
    function transferFrom(address _from, address _to, uint256 _amount)
        public returns (bool);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    /// its behalf
    /// @param _spender The address of the approved spender
    /// @param _amount The amount of tokens to transfer
    function approve(address _spender, uint256 _amount) public returns (bool);
}


contract PayableERC20Abstract is ERC20Abstract, WithdrawableMinAbstract
{
/* Constants */

    // Token decimal places
    uint8 constant DECIMALS = 18;
    
    // Unit token multiplier
    uint192 constant TOKEN = uint192(10)**DECIMALS;
    
    // 0.2% of tokens are awarded to creator
    uint192 constant COMMISION_DIV = 500;
    
    // Tokens and their ether untouched for 3 years
    // can be salvaged by anyone
    uint64 public constant ORPHANED_PERIOD = 3 * 365 days;
    

/* Structs */

    // Holder state takes 3 slots + 'allowed' mapping
    struct Holder {
        // Token balance.
        uint192 balance;
        
        // Last time the account was touched.
        uint64 lastTouched;
        
        // The totalDeposits at the time of last claim.
        uint lastSumDeposits;
        
        // Ether balance
        uint etherBalance;
        
        // Thirdparty sender allownaces
        mapping (address => uint) allowed;
    }

/* State Valiables */

    // Mapping of holder accounts
    mapping (address => Holder) holders;

/* Events */

    /// @dev Triggered upon a redistribution of untouched tokens
    /// @param _from The orphaned address
    /// @param _to The claiming address
    /// @param _amount The amount of tokens salvaged
    /// @param _value The value of ether salvaged
    event OrphanedTokensClaim(
        address indexed _from,
        address indexed _to,
        uint _amount,
        uint _value);

    /// @dev Logged upon calling `callAsContract()`
    /// @param _kAddr A contract address that was called
    /// @param _value A value of ether sent with the transaction
    /// @param _data Call data sent with the transaction
    event ExternalCall(
        address indexed _kAddr,
        uint _value,
        bytes _data);

/* Modifiers */

/* Function Abstracts */

    /// @dev Deposits only receivable by the default account. Minimum gas is
    /// required as no state is mutated. 
    function() public payable;

    /// @return The total deposits recived by the contract since deployment
    function deposits() public view returns (uint);
    
    /// @param _addr An Ethereum address
    /// @return The balance of ether withdrawable by `_addr`
    function etherBalanceOf(address _addr) public view returns (uint);

    /// @return Timestamp when an account is considered orphaned
    function orphanedAfter(address _addr) public view returns (uint);

    /// @param _addr An address to enquire current orphan state
    /// @return Boolean value as to the whether the address is orphaned or not
    function isOrphaned(address _addr) public view returns (bool);

    /// @notice Claim tokens of orphaned account `_addr`
    /// @param _addr Address of orphaned account
    /// @return _bool
    function salvageOrphanedTokens(address _addr) public returns (bool);
    
    /// @notice Refresh the time to orphan of holder account `_addr`
    /// @param _addrs An array of holder addresses to touch
    /// @return success
    function touch(address[] _addrs) public returns (bool);

    /// @notice Transfer `_value` tokens from ERC20 contract at `_addr` to `_to`
    /// @param _kAddr Address of and external ERC20 contract
    /// @param _to An address to transfer external tokens to.
    /// @param _value number of tokens to be transferred
    function transferExternalTokens(address _kAddr, address _to, uint _value)
        public returns (bool);

    /// @notice Withdraw the ether balance of `msg.sender`
    /// @return Boolean success value
    function withdrawAll() public returns (bool);

    /// @notice Push payments for an array of addresses
    /// @param _addrs An array of addresses to process withdrawals for
    /// @return Boolean success value
    function withdrawAllFor(address[] _addrs) public returns (bool);

}


contract PayableERC20 is
    ReentryProtected,
    RegBase,
    PayableERC20Abstract
{
    using Math for uint;
    using Math for uint64;
    using Math for uint192;

/* Constants */
    
    /// @return Contract version constant
    bytes32 public constant VERSION = "PayableERC20 v0.4.4";

/* State Valiables */

    // The summation of ether deposited up to when a holder last triggered a 
    // claim
    uint sumDeposits;
    
    // The contract balance at last claim (transfer or withdraw)
    uint lastBalance;
    
    // The address that created the contract
    address public creator;
    
    uint public __initFuse = 1;

/* Functions Public non-constant*/

    // This is a SandalStraps Framework compliant constructor
    constructor(address _creator, bytes32 _regName, address _owner)
        public
        RegBase(_creator, _regName, _owner)
    {
        creator = _creator == 0x0 ? owner : _creator;
        decimals = DECIMALS;
    }

    // Can receive ether payments unconditionally
    function()
        public
        payable
    {
        require(__initFuse == 0);
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }
    
//
// Getters
//

    // Return token balance for `_addr` 
    function balanceOf(address _addr)
        public
        view
        returns (uint)
    {
        return holders[_addr].balance;
    }
    
    // Return ether balance for `_addr`
    function etherBalanceOf(address _addr)
        public
        view
        returns (uint)
    {
        return holders[_addr].etherBalance.add(claimableEther(holders[_addr]));
    }

    // Standard ERC20 3rd party sender allowance getter
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint remaining_)
    {
        return holders[_owner].allowed[_spender];
    }

    // Return total deposits made to the contract since deployment
    function deposits()
        public
        view
        returns (uint)
    {
        return sumDeposits.add(address(this).balance - lastBalance); 
    }

    // Return an epoch time after which the account is orphaned
    function orphanedAfter(address _addr)
        public
        view
        returns (uint)
    {
        return holders[_addr].lastTouched.add(ORPHANED_PERIOD);
    }
    
    // Return the orphaned state of `_addr`
    function isOrphaned(address _addr)
        public
        view
        returns (bool)
    {
        return now > holders[_addr].lastTouched.add(ORPHANED_PERIOD);
    }

//
// ERC20 and Orphaned Tokens Functions
//

    // ERC20 standard tranfer. Send _value amount of tokens to address _to
    // Reentry protection prevents attacks upon the state
    function transfer(address _to, uint _amount)
        public
        noReentry
        returns (bool)
    {
        xfer(msg.sender, _to, _amount);
        return true;
    }

    // ERC20 standard tranferFrom. Send _value amount of tokens from address 
    // _from to address _to
    // Reentry protection prevents attacks upon the state
    function transferFrom(address _from, address _to, uint _amount)
        public
        noReentry
        returns (bool)
    {
        // Validate and adjust allowance
        require(_amount <= holders[_from].allowed[msg.sender]);
        
        // Adjust spender allowance
        holders[_from].allowed[msg.sender] = 
            holders[_from].allowed[msg.sender].sub(_amount);
        
        xfer(_from, _to, _amount);
        return true;
    }

    // Overload the ERC20 xfer() to account for unclaimed ether
    function xfer(address _from, address _to, uint _amount)
        internal
    {
        require(__initFuse == 0);
        // Cache holder structs from storage to memory to avoid excessive SSTORE
        Holder memory from = holders[_from];
        Holder memory to = holders[_to];
        
        // Cannot transfer to self or the contract
        require(_from != _to);
        require(_to != address(this));

        // Validate amount
        require(_amount <= from.balance);
        
        // Update outstanding ether balance claims
        claimEther(from);
        claimEther(to);
        
        // Transfer tokens
        from.balance = from.balance.sub(_amount).to192();
        to.balance = to.balance.add(_amount).to192();

        // Commit changes to storage
        holders[_from] = from;
        holders[_to] = to;

        emit Transfer(_from, _to, _amount);
    }

    // Approves a third-party spender
    function approve(address _spender, uint _amount)
        public
        noReentry
        returns (bool)
    {
        require(holders[msg.sender].balance != 0);
        
        holders[msg.sender].allowed[_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    // Salvage alien tokens that may have been sent to the contract
    function transferExternalTokens(address _kAddr, address _to, uint _amount)
        public
        onlyOwner
        returns(bool)
    {
        return ERC20Abstract(_kAddr).transfer(_to, _amount);
    }

    // Reset the time to orphan countdown for an array of addresses
    function touch(address[] _addrs)
        public
        noReentry
        returns (bool)
    {
        for(uint i; i< _addrs.length; i++) {
            if(holders[_addrs[i]].balance > 0) {
                holders[_addrs[i]].lastTouched = now.to64();
            }
        }
        return true;
    }

    // Salvage orphaned tokens. Can be called by anyone. If owner is orphaned
    // ownership is awarded to caller
    function salvageOrphanedTokens(address _addr)
        public
        noReentry
        returns(bool)
    {
        // Claim ownership if owner address itself has been orphaned
        if (now > orphanedAfter(owner)) {
            emit ChangedOwner(owner, msg.sender);
            owner = msg.sender;
        }
        
        // Caller must be owner
        require(msg.sender == owner);
        
        // Orphan account must have exceeded shelflife
        require(now > orphanedAfter(_addr));
        
        // Log claim
        emit OrphanedTokensClaim(
            _addr,
            msg.sender,
            holders[_addr].balance,
            holders[_addr].etherBalance);

        // Transfer orphaned tokens
        xfer(_addr, msg.sender, holders[_addr].balance);
        
        // Transfer ether. Orphaned ether was claimed during token transfer.
        holders[msg.sender].etherBalance = 
            holders[msg.sender].etherBalance.add(holders[_addr].etherBalance);
        
        // Delete ophaned account
        delete holders[_addr];

        return true;
    }

//
// Payment distribution functions
//

    // Ether balance delta for holder's unclaimed ether
    // function claimableDeposits(address _addr)
    function claimableEther(Holder holder)
        internal
        view
        returns (uint)
    {
        return uint(holder.balance).mul(
            deposits().sub(holder.lastSumDeposits)
            ).div(totalSupply);
    }
    
    // Claims share of ether deposits
    // before withdrawal or change to token balance.
    function claimEther(Holder holder)
        internal
        returns(Holder)
    {
        // Update unprocessed deposits
        if (lastBalance != address(this).balance) {
            sumDeposits = sumDeposits.add(address(this).balance.sub(lastBalance));
            lastBalance = address(this).balance;
        }

        // Claim share of deposits since last claim
        holder.etherBalance = holder.etherBalance.add(claimableEther(holder));
        
        // Snapshot deposits summation
        holder.lastSumDeposits = sumDeposits;

        // Reset orhpan timer
        holder.lastTouched = now.add(ORPHANED_PERIOD).to64();

        return holder;
    }

//
// Withdrawal processing functions
//

    // Withdraw the calling address's available balance
    function withdrawAll()
        public
        noReentry
        returns (bool)
    {
        return intlWithdraw(msg.sender, msg.sender);
    }

    // Push ether payments for an array of addresses
    function withdrawAllFor(address[] _addrs)
        public
        noReentry
        returns (bool)
    {
        for(uint i; i < _addrs.length; i++) {
            intlWithdraw(_addrs[i], _addrs[i]);
        }
        return true;
    }

    // Account withdrawl function
    function intlWithdraw(address _from, address _to)
        internal
        returns (bool)
    {
        Holder memory holder = holders[_from];
        claimEther(holder);
        
        // check balance and withdraw on valid amount
        uint value = holder.etherBalance;
        require(value > 0);
        holder.etherBalance = 0;
        holders[_from] = holder;
        
        // snapshot adjusted contract balance
        lastBalance = lastBalance.sub(value);
        
        emit Withdrawal(_from, _to, value);
        _to.transfer(value);
        return true;
    }

//
// Contract managment functions
//

    // Owner can selfdestruct the contract on the condition it has near zero
    // balance
    function destroy()
        public
        noReentry
        onlyOwner
    {
        // must flush all ether balances first. But imprecision may have
        // accumulated  under 100,000,000,000 wei
        require(address(this).balance <= 100000000000);
        selfdestruct(msg.sender);
    }

    // Set name and symbol of the token
    function _init(string _name, string _symbol, uint _supply)
        public
        onlyOwner
        returns (bool)
    {
        require(__initFuse == 1);
        require(_supply > 0);
        name = _name;
        symbol = _symbol;
        totalSupply = _supply * TOKEN;
        uint commission = totalSupply / COMMISION_DIV;
        
        // Mint tokens to owner and commission addresses
        holders[owner].balance = totalSupply.sub(commission).to192();
        holders[owner].lastTouched = now.to64();
        emit Transfer(0x0, owner, totalSupply.sub(commission));
        
        holders[creator].balance = 
                holders[creator].balance.add(commission).to192();
        holders[creator].lastTouched = now.to64();
        emit Transfer(0x0, creator, commission);
        
        delete __initFuse;
        return true;
    }

    // Perform a low level call to another contract
    function callAsContract(address _kAddr, bytes _data)
        public
        payable
        onlyOwner
        preventReentry
        returns (bool success_)
    {
        emit ExternalCall(_kAddr, msg.value, _data);
        success_ = _kAddr.call.value(msg.value)(_data);
    }
}


contract PayableERC20Factory is Factory
{
//
// Constants
//

    bytes32 constant public regName = "payableerc20";
    bytes32 constant public VERSION = "PayableERC20Factory v0.4.4";

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
        _regName; // Not passed to super. Quiet compiler warning
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
        kAddr_ = address(new PayableERC20(this, _regName, _owner));
        emit Created(msg.sender, _regName, kAddr_);
    }
}

