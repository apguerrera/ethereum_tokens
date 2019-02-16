/*
file:   EscrowingITO.sol
ver:    0.4.3
author: Darryl Morris
date:   3-Sep-2018
email:  o0ragman0o AT gmail.com
(c) Darryl Morris 2018

A SandalStraps compliant contract set for an 'Initial Token Offering' containing
refund if fail and inter-token transfer/notification features.

Deployment
----------
Call `createNew(name, owner)` from the predeployed factory at:
0xTODO
Note the address of the EscrowingITO contract created from the logged event.

Initialization
--------------
The owner must call the `_init()` function supplying the following parameters
before the ITO can proceed:

`_name`         An ERC20 name string for the token
`_symbol`       An ERC20 trading symbol string for the token
`_fundWallet`   An address to receive raised funds
`_minCap`       A minimum funding cap in units of ether (maxCap will be 10x minCap)
`_kycLimit`     An amount over which an individual funder requires KYC. A value
                greater than 10x _minCap will not flag any investor for KYC
`_startDate`    A Unix time in seconds at which funding will start.
                Must be greater than 3 days since initialization to allow for audit.

Constant configuration:
----------------------
* Minimum of 3 day audit period between deployment and start date
* 28 day funding period (may be finalized earlier if minimum cap is reached)
* 1000 tokens/eth
* 8 decimal places
* Maximum funding cap 10 times greater than minimum funding cap to force
  a realistic funding band

Operation
---------
The funding period is from the start date up to 28 days or when the owner calls
`finalizeITO()` once `minCap` has been reached. The owner may call `abort()`
any time before `finalizeITO()` has been called. If 35 days has passed and the
owner has not called `finalizeITO()` or `abort()` anyone can call `abort()` and
call `withdrawAll()` to recover their funds.

If `minCap` is not reached by `endDate`, funders can call `withdrawAll()` to
recover their funds.

Funding stop if aborted, `maxCap` is reached, endDate is reached and or 
finalizeITO() is successfullly called.
Once `finalizeITO()` has been successfully called, funds are transferred to the
fund and commission wallets and token transfers are permitted.

License
-------
This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

Release Notes
-------------
0.4.1
* Fixed incorrect explicit return bug in `preventReentry` modified functions.
  Proper method is to use named return parameters
* Added `VERSION` to main contract

*/


pragma solidity ^0.4.24;

import "https://github.com/o0ragman0o/SandalStraps/contracts/Factory.sol";

library SafeMath
{
    // a add to b
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        assert(c >= a);
    }
    
    // a subtract b
    function sub(uint a, uint b) internal pure returns (uint c) {
        c = a - b;
        assert(c <= a);
    }
    
    // a multiplied by b
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        assert(a == 0 || c / a == b);
    }
    
    // a divided by b
    function div(uint a, uint b) internal pure returns (uint c) {
        assert(b != 0);
        c = a / b;
    }
}


contract ReentryProtected
{
    // The reentry protection state mutex.
    bool __reMutex;

    // Sets and resets mutex in order to block functin reentry
    modifier preventReentry() {
        require(!__reMutex);
        __reMutex = true;
        _;
        delete __reMutex;
    }

    // Blocks function entry if mutex is set
    modifier noReentry() {
        require(!__reMutex);
        _;
    }
}


contract ERC20Token
{
    using SafeMath for uint;

/* Constants */

    // none
    
/* State variable */

    /// @return The Total supply of tokens
    uint public totalSupply;
    
    /// @return ERC20 Name
    string public name;
    
    /// @return Token symbol
    string public symbol;
    
    // Token ownership mapping
    mapping (address => uint) balances;
    
    // Allowances mapping
    mapping (address => mapping (address => uint)) allowed;

/* Events */

    // Triggered when tokens are transferred.
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _amount);

    // Triggered whenever approve(address _spender, uint256 _amount) is called.
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount);

/* Modifiers */

    // none
    
/* Functions */

    // Using an explicit getter allows for function overloading    
    function balanceOf(address _addr)
        public
        view
        returns (uint)
    {
        return balances[_addr];
    }
    
    // Using an explicit getter allows for function overloading    
    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint)
    {
        return allowed[_owner][_spender];
    }

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _amount)
        public
        returns (bool)
    {
        return xfer(msg.sender, _to, _amount);
    }

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _amount)
        public
        returns (bool)
    {
        require(_amount <= allowed[_from][msg.sender]);
        
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        return xfer(_from, _to, _amount);
    }

    // Process a transfer internally.
    function xfer(address _from, address _to, uint _amount)
        internal
        returns (bool)
    {
        require(_amount <= balances[_from]);

        emit Transfer(_from, _to, _amount);
        
        // avoid wasting gas on 0 token transfers
        if(_amount == 0) return true;
        
        balances[_from] = balances[_from].sub(_amount);
        balances[_to]   = balances[_to].add(_amount);
        
        return true;
    }

    // Approves a third-party spender
    function approve(address _spender, uint256 _amount)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
}



/*-----------------------------------------------------------------------------\

## Conditional Entry Table

Functions must throw on F conditions

Renetry prevention is on all public mutating functions
Reentry mutex set in finalizeITO(), externalXfer(), refund()

|function                |<startDate |<endDate  |fundFailed  |fundSucceeded|itoSucceeded
|------------------------|:---------:|:--------:|:----------:|:-----------:|:---------:|
|()                      |F          |T         |F           |T            |F          |
|_init()                 |__initFuse |F         |F           |F            |F          |
|abort()                 |T          |T         |T           |T            |F          |
|proxyPurchase()         |F          |T         |F           |T            |F          |
|finalizeITO()           |F          |F         |F           |T            |T          |
|refund()                |F          |F         |T           |F            |F          |
|transfer()              |F          |F         |F           |F            |!mustKYC   |
|transferFrom()          |F          |F         |F           |F            |!mustKYC   |
|approve()               |F          |F         |F           |F            |T          |
|clearKyc()              |T          |T         |T           |T            |T          |
|changeOwner()           |T          |T         |T           |T            |T          |
|acceptOwnership()       |T          |T         |T           |T            |T          |
|transferExternalTokens()|T          |T         |T           |T            |T          |
|destroy()               |F          |F         |!__abortFuse|F            |F          |

\*----------------------------------------------------------------------------*/

contract EscrowingITOAbstract
{
    // Logged when the contract recieves ether
    event Deposit(address indexed _from, uint _value);
    
    // Logged when ether is sent from the contract
    event Withdrawal(address indexed _from, address indexed _to, uint _value);
    
    // Logged when new owner accepts ownership
    event ChangedOwner(address indexed _from, address indexed _to);
    
    // Logged when owner initiates a change of ownership
    event ChangeOwnerTo(address indexed _to);
    
    // Logged when a funder exceeds the KYC limit or cleared
    event Kyc(address indexed _addr, bool _kyc);

//
// Constants
//

    // 8 Decimal places for ERC20 token (Smallest subtoken is 0.00000001)
    uint public constant decimals = 18;

    // 1000 Tokens created per ether invested.
    uint public constant TOKENS_PER_ETH  = 1000;

    // Period for fundraising. Can be finalized earlier if minimum fund is raised.
    uint public constant FUNDING_PERIOD  = 28 days;
    
    // The maximum cap is bound to 10x the minimum cap
    uint constant MAX_FUNDING_BOUND = 10;

//
// State Variables
//

    /// @dev The initialization fuse blows on calling _init()
    /// @return Initialization state. true == uninitialized;
    bool public __initFuse = true;
   
    /// @dev This fuse blows upon calling abort() which forces a fail state
    /// @return the abort state. true == not aborted
    bool public __abortFuse = true;
    
    /// @dev Sets to true after the fund is swept to the fund wallet, allows token
    /// transfers and prevents abort()
    /// @return final success state of ITO
    bool public itoSuccessful;

    /// @return Developer's commision wallet (awarded 0.5% of funds raise)
    address public devWallet;
    
    /// @return Wallet address into which successfully raised funds will be moved
    address public fundWallet;

    /// @return Total ether raised during funding
    uint public etherRaised;
    
    /// @return KYC funding limit above which KYC flags will prevent an address
    /// from transferring tokens until cleared by owner
    uint public kycLimit;
    
    /// @return Total ether refunded. Used to permision call to `destroy()`
    uint public refunded;

    /// @return Minimum funds required for fund to be successful
    uint public minCap;
    
    /// @return Maximum funds allowed to be raised
    uint public maxCap;
    
    /// @return The date after which funding will be accepted
    uint public startDate;
    
    /// @return The date after which further funding will be rejected
    uint public endDate;
    
    /// @return Ether paid by an address
    mapping (address => uint) public etherContributed;

    /// @return KYC state of an address
    mapping (address => bool) public mustKyc;

    /// @notice Initialize the ITO
    /// @param _name A name for the token
    /// @param _symbol A trading symbol for the token
    /// @param _fundWallet An address to receive raised funds
    /// @param _minCap A minimum funding cap in units of ether (maxCap will be
    /// 10x minCap)
    /// @param _kycLimit An amount over which an individual funder requires KYC
    /// @param _startDate A Unix time in seconds for funding to start
    function _init(string _name, string _symbol, address _fundWallet,
        uint _minCap, uint _kycLimit, uint _startDate) public returns (bool);

    /// @return `true` if MIN_FUNDS were raised
    function fundSucceeded() public view returns (bool);
    
    /// @return `true` if MIN_FUNDS were not raised before endDate or contract 
    /// has been aborted
    function fundFailed() public view returns (bool);

    /// @param _eth A value of ether in units of wei
    /// @return token/ether conversion given ether value 
    function ethToTokens(uint _eth) public view returns (uint);

    /// @notice Processes a token purchase for `_addr`
    /// @param _addr An address to purchase tokens
    /// @return Boolean success value
    function proxyPurchase(address _addr) public payable returns (bool);

    /// @notice Finalize the ITO and transfer funds
    /// @return Boolean success value
    function finalizeITO() public returns (bool);
    
    /// @notice Clear KYC flag for `_addr`
    /// @param _addrs An array of KYC'd address
    /// @return Boolean success value
    function clearKyc(address[] _addrs) public returns (bool);
    
    /// @notice Claim refund on failed ITO
    /// @return Boolean success value
    function withdrawAll() public returns (bool);
    
    /// @notice Push refund for `_addr` from failed ITO
    /// @param _addrs An array of address to withdraw for
    /// @return Boolean success value
    function withdrawAllFor(address[] _addrs) public returns (bool);

    /// @notice Abort the token sale prior to finalizeITO() 
    function abort() public returns (bool);

    /// @notice Transfer bulk tokens from `msg.sender`
    /// @param _addrs An array of recipient addresses
    /// @param _amounts An array of token amounts to transfer for respective addresses
    /// @return Boolean success value
    function transferToMany(address[] _addrs, uint[] _amounts) public returns (bool);

    /// @notice Salvage `_amount` tokens at `_kaddr` and send them to `_to`
    /// @param _kAddr An ERC20 contract address
    /// @param _to and address to send tokens
    /// @param _amount The number of tokens to transfer
    /// @return Boolean success value
    function transferExternalToken(address _kAddr, address _to, uint _amount)
        public returns (bool);
}


/*-----------------------------------------------------------------------------\

 EscrowingITO implimentation

\*----------------------------------------------------------------------------*/

contract EscrowingITO is 
    ReentryProtected,
    RegBase,
    ERC20Token,
    EscrowingITOAbstract
{
    using SafeMath for uint;

//
// Constants
//

    bytes32 public constant VERSION = "EscrowingITO v0.4.3";

    // Token fixed point for decimal places
    uint constant TOKEN = uint(10)**decimals; 
    
    // 1% commission divisor
    uint constant COMMISSION_DIV = 100;

    // A deployment cannot accept funding before a post deployed audit period
    uint public constant AUDIT_PERIOD = 3 days;

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
        RegBase(_creator, _regName, _owner)
    {
        // Factory address to collect commision
        devWallet = _creator;
    }

    // Default function. Accepts payments during funding period
    function ()
        public
        payable
    {
        // Pass through to purchasing function. Will throw on failed or
        // successful ITO
        proxyPurchase(msg.sender);
    }

    // Constructor
    function _init(
        string _name,
        string _symbol,
        address _fundWallet,
        uint _minCap,
        uint _kycLimit,
        uint _startDate
        )
        public
        onlyOwner
        returns (bool)
    {
        require(__initFuse);
        // Enforce the audit period 
        require(_startDate >= now + AUDIT_PERIOD);
        require(_minCap != 0);

        owner       = msg.sender;
        name        = _name;
        symbol      = _symbol;
        fundWallet  = _fundWallet == 0x0 ? msg.sender : _fundWallet;
        
        // minCap in units of ether
        minCap      = _minCap.mul(1 ether);
        
        // maxCap is bounded to 10x  minCap
        maxCap      = _minCap.mul(1 ether).mul(MAX_FUNDING_BOUND);
        
        // KYC limit in units of ether.
        // Setting _kycLimit at or above maxCap means no KYC will be required
        kycLimit    = _kycLimit == 0 ? maxCap : _kycLimit;

        // Start date in Unix time seconds
        startDate   = _startDate;
        endDate     = _startDate + FUNDING_PERIOD;
        
        delete __initFuse;
        return true;
    }
    
//
// Getters
//

    // ITO fails if aborted or minimum funds are not raised by the end date
    function fundFailed() public view returns (bool)
    {
        return !__abortFuse
            || (now > endDate  && etherRaised < minCap);
    }
    
    // Funding succeeds if not aborted, minimum funds are raised before end date
    function fundSucceeded() public view returns (bool)
    {
        return !__initFuse
            && !fundFailed()
            && etherRaised >= minCap;
    }

    // Returns the number of tokens for given amount of ether for an address 
    function ethToTokens(uint _wei) public view returns (uint)
    {
        // Exclude all cases where tokens are not created
        return
            __initFuse ? 0 :
            fundFailed() ? 0 :
            itoSuccessful ? 0 :
            now < startDate ? 0 :
            now > endDate ? 0 :
            _wei + etherRaised > maxCap ? 0 : 
            _wei.div(TOKEN);
    }

//
// ITO functions
//

    // The fundraising can be aborted any time before `finaliseITO()` is called.
    // This will force a fail state and allow refunds to be collected.
    // The owner can abort or anyone else if a successful fund has not been
    // finalised before 7 days after the end date.
    function abort()
        public
        noReentry
        returns (bool)
    {
        require(!itoSuccessful);
        require(msg.sender == owner || now > endDate  + 7 days);
        delete __abortFuse;
        return true;
    }
    
    // General addresses can purchase tokens during funding
    function proxyPurchase(address _addr)
        public
        payable
        noReentry
        returns (bool)
    {
        // Get ether to token conversion
        uint tokens = ethToTokens(msg.value);
        
        // Throw if no tokens are going to be created
        require(tokens != 0);
        
        emit Deposit(_addr, msg.value);
        
        // Mint and transfer tokens
        balances[_addr] = balances[_addr].add(tokens);
        totalSupply = totalSupply.add(tokens);
        emit Transfer(0x0, _addr, tokens);
        
        // Update holder payments
        etherContributed[_addr] = etherContributed[_addr].add(msg.value);
        
        // Check KYC requirement
        if(etherContributed[_addr] > kycLimit && !mustKyc[_addr]) {
            mustKyc[_addr] = true;
            emit Kyc(_addr, true);
        }
        
        // Update funds raised
        etherRaised = etherRaised.add(msg.value);
        return true;
    }
    
    // Owner can sweep a successful funding to the fundWallet
    // Contract can be aborted up until this action.
    function finalizeITO()
        public
        onlyOwner
        preventReentry()
        returns (bool success_)
    {
        require(fundSucceeded());

        itoSuccessful = true;

        // 1% Developer commission
        emit Withdrawal(this, devWallet, address(this).balance.div(COMMISSION_DIV));
        devWallet.transfer(address(this).balance.div(COMMISSION_DIV));

        // Remaining 99% to the fund wallet
        emit Withdrawal(this, fundWallet, address(this).balance);
        fundWallet.transfer(address(this).balance);
        success_ = true;
    }
    
    // Direct refund to caller
    function withdrawAll()
        public
        returns (bool)
    {
        address[] memory arr = new address[](1);
        arr[0] = msg.sender;
        return withdrawAllFor(arr);
    }
    
    // Refunds can be claimed from a failed ITO. Using `Withdrawable API`
    function withdrawAllFor(address[] _addrs)
        public
        preventReentry()
        returns (bool success_)
    {
        if(!fundFailed()) {
            return false;
        }
        
        for(uint i; i < _addrs.length; i++) {
            address addr = _addrs[i];
            uint value = etherContributed[addr];

            if(value > 0) {
                // Show burned tokens in ledger
                totalSupply = totalSupply.sub(balances[addr]);
                emit Transfer(addr, 0x0, balances[addr]);
        
                // garbage collect
                delete balances[addr];
                delete etherContributed[addr];
        
                emit Withdrawal(addr, addr, value);
                refunded = refunded.add(value);
                addr.transfer(value);
            }
        }
        success_ = true;
    }
    
    function clearKyc(address[] _addrs)
        public
        noReentry
        onlyOwner
        returns (bool)
    {
        for(uint i; i < _addrs.length; i++) {
            emit Kyc(_addrs[i], false);
            delete mustKyc[_addrs[i]];
        }
        return true;
    }

//
// ERC20 additional and overloaded functions
//

    // Allows a sender to transfer tokens to an array of recipients
    function transferToMany(address[] _addrs, uint[] _amounts)
        public
        noReentry
        returns (bool)
    {
        require(_addrs.length == _amounts.length);
        uint len = _addrs.length;
        for(uint i = 0; i < len; i++) {
            xfer(msg.sender, _addrs[i], _amounts[i]);
        }
        return true;
    }

    // Overload to check ITO success and KYC flags.
    function xfer(address _from, address _to, uint _amount)
        internal
        noReentry
        returns (bool)
    {
        require(itoSuccessful);
        require(!mustKyc[_from]);
        super.xfer(_from, _to, _amount);
        return true;
    }

    // Overload to require ITO success
    function approve(address _spender, uint _amount)
        public
        noReentry
        returns (bool)
    {
        // ITO must be successful
        require(itoSuccessful);
        super.approve(_spender, _amount);
        return true;
    }

//
// Contract management functions
//

    // The contract can be selfdestructed after abort and all refunds have been
    // withdrawn.
    function destroy()
        public
        noReentry
        onlyOwner
    {
        require(!__abortFuse);
        require(refunded == etherRaised);
        selfdestruct(owner);
    }
    
    // Owner can salvage ERC20 tokens that may have been sent to the account
    function transferExternalToken(address _kAddr, address _to, uint _amount)
        public
        onlyOwner
        preventReentry
        returns (bool success_) 
    {
        require(ERC20Token(_kAddr).transfer(_to, _amount));
        success_ = true;
    }
}


contract EscrowingITOFactory is Factory
{
//
// Constants
//

    /// @return registrar name
    bytes32 constant public regName = "escrowingito";
    
    /// @return version string
    bytes32 constant public VERSION = "EscrowingITOFactory v0.4.3";

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
        returns (address kAddr_)
    {
        _owner = _owner == 0x0 ? msg.sender : _owner;
        kAddr_ = address(new EscrowingITO(this, _regName, _owner));
        emit Created(msg.sender, _regName, kAddr_);
    }
}
