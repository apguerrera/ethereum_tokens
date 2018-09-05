# DeveryPresaleWhitelist

Source file [../contracts/DeveryPresaleWhitelist.sol](../contracts/DeveryPresaleWhitelist.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.17;

// ----------------------------------------------------------------------------
// Devery Presale Whitelist
//
// Deployed to : 0x38E330C4330e743a4D82D93cdC826bAe78C6E7A6
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd for Devery 2017. The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
// BK Ok
contract Owned {

    // ------------------------------------------------------------------------
    // Current owner, and proposed new owner
    // ------------------------------------------------------------------------
    // BK Next 2 Ok
    address public owner;
    address public newOwner;

    // ------------------------------------------------------------------------
    // Constructor - assign creator as the owner
    // ------------------------------------------------------------------------
    // BK Ok - Constructor
    function Owned() public {
        // BK Ok
        owner = msg.sender;
    }


    // ------------------------------------------------------------------------
    // Modifier to mark that a function can only be executed by the owner
    // ------------------------------------------------------------------------
    // BK Ok
    modifier onlyOwner {
        // BK Ok
        require(msg.sender == owner);
        // BK Ok
        _;
    }


    // ------------------------------------------------------------------------
    // Owner can initiate transfer of contract to a new owner
    // ------------------------------------------------------------------------
    // BK Ok - Only owner can execute
    function transferOwnership(address _newOwner) public onlyOwner {
        // BK Ok
        newOwner = _newOwner;
    }


    // ------------------------------------------------------------------------
    // New owner has to accept transfer of contract
    // ------------------------------------------------------------------------
    // BK Ok - Only new owner can execute
    function acceptOwnership() public {
        // BK Ok
        require(msg.sender == newOwner);
        // BK Ok - Log event
        OwnershipTransferred(owner, newOwner);
        // BK Next 2 Ok
        owner = newOwner;
        newOwner = 0x0;
    }
    // BK Ok - Event
    event OwnershipTransferred(address indexed _from, address indexed _to);
}


// ----------------------------------------------------------------------------
// Administrators
// ----------------------------------------------------------------------------
// BK Ok
contract Admined is Owned {

    // ------------------------------------------------------------------------
    // Mapping of administrators
    // ------------------------------------------------------------------------
    // BK Ok
    mapping (address => bool) public admins;

    // ------------------------------------------------------------------------
    // Add and delete adminstrator events
    // ------------------------------------------------------------------------
    // BK Next 2 Ok - Events
    event AdminAdded(address addr);
    event AdminRemoved(address addr);


    // ------------------------------------------------------------------------
    // Modifier for functions that can only be executed by adminstrator
    // ------------------------------------------------------------------------
    // BK Ok
    modifier onlyAdmin() {
        // BK Ok
        require(admins[msg.sender] || owner == msg.sender);
        // BK Ok
        _;
    }


    // ------------------------------------------------------------------------
    // Owner can add a new administrator
    // ------------------------------------------------------------------------
    // BK Ok - Only owner can execute
    function addAdmin(address addr) public onlyOwner {
        // BK Ok
        admins[addr] = true;
        // BK Ok - Log event
        AdminAdded(addr);
    }


    // ------------------------------------------------------------------------
    // Owner can remove an administrator
    // ------------------------------------------------------------------------
    // BK Ok - Only owner can execute
    function removeAdmin(address addr) public onlyOwner {
        // BK Ok
        delete admins[addr];
        // BK Ok - Log event
        AdminRemoved(addr);
    }
}


// ----------------------------------------------------------------------------
// Devery Presale Whitelist
// ----------------------------------------------------------------------------
// BK Ok
contract DeveryPresaleWhitelist is Admined {

    // ------------------------------------------------------------------------
    // Administrators can add until sealed
    // ------------------------------------------------------------------------
    // BK Ok
    bool public sealed;

    // ------------------------------------------------------------------------
    // The whitelist of accounts and max contribution
    // ------------------------------------------------------------------------
    // BK Ok
    mapping(address => uint) public whitelist;

    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------
    // BK Ok - Event
    event Whitelisted(address indexed addr, uint max);


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    // BK Ok - Constructor
    function DeveryPresaleWhitelist() public {
    }


    // ------------------------------------------------------------------------
    // Add to whitelist
    // ------------------------------------------------------------------------
    // BK Ok - Only admin can execute
    function add(address addr, uint max) public onlyAdmin {
        // BK Ok
        require(!sealed);
        // BK Ok
        require(addr != 0x0);
        // BK Ok
        whitelist[addr] = max;
        // BK Ok - Log event
        Whitelisted(addr, max);
    }


    // ------------------------------------------------------------------------
    // Add batch to whitelist
    // ------------------------------------------------------------------------
    // BK Ok - Only admin can execute
    function multiAdd(address[] addresses, uint[] max) public onlyAdmin {
        // BK Ok
        require(!sealed);
        // BK Ok
        require(addresses.length != 0);
        // BK Ok
        require(addresses.length == max.length);
        // BK Ok
        for (uint i = 0; i < addresses.length; i++) {
            // BK Ok
            require(addresses[i] != 0x0);
            // BK Ok
            whitelist[addresses[i]] = max[i];
            // BK Ok - Log event
            Whitelisted(addresses[i], max[i]);
        }
    }


    // ------------------------------------------------------------------------
    // After sealing, no more whitelisting is possible
    // ------------------------------------------------------------------------
    // BK Ok - Only owner can execute
    function seal() public onlyOwner {
        // BK Ok
        require(!sealed);
        // BK Ok
        sealed = true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ethers - no payable modifier
    // ------------------------------------------------------------------------
    // BK Ok
    function () public {
    }
}
```
