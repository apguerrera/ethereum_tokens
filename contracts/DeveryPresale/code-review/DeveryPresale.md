# DeveryPresale

Source file [../contracts/DeveryPresale.sol](../contracts/DeveryPresale.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// 'PREVE' 'Presale EVE Tokens' token contract
//
// Deployed to : {TBA}
// Symbol      : PREVE
// Name        : Presale EVE Tokens
// Total supply: Minted
// Decimals    : 18
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd for Devery 2017. The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Devery Presale Whitelist Interface
// ----------------------------------------------------------------------------
// BK Ok
contract DeveryPresaleWhitelist {
    // BK Ok
    mapping(address => uint) public whitelist;
}


// ----------------------------------------------------------------------------
// Parity PICOPS Whitelist Interface
// ----------------------------------------------------------------------------
// BK Ok
contract PICOPSCertifier {
    // BK Ok
    function certified(address) public constant returns (bool);
}


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
// BK Ok
contract SafeMath {
    // BK Ok
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        // BK Ok
        c = a + b;
        // BK Ok
        require(c >= a);
    }
    // BK Ok
    function safeSub(uint a, uint b) public pure returns (uint c) {
        // BK Ok
        require(b <= a);
        // BK Ok
        c = a - b;
    }
    // BK Ok
    function safeMul(uint a, uint b) public pure returns (uint c) {
        // BK Ok
        c = a * b;
        // BK Ok
        require(a == 0 || c / a == b);
    }
    // BK Ok
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        // BK Ok
        require(b > 0);
        // BK Ok
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
// BK Ok
contract ERC20Interface {
    // BK Ok
    function totalSupply() public constant returns (uint);
    // BK Ok
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    // BK Ok
    function transfer(address to, uint tokens) public returns (bool success);
    // BK Ok
    function approve(address spender, uint tokens) public returns (bool success);
    // BK Ok
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    // BK Next 2 Ok - Events
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
// BK Ok
contract Owned {
    // BK Next 2 Ok
    address public owner;
    address public newOwner;

    // BK Ok - Event
    event OwnershipTransferred(address indexed _from, address indexed _to);

    // BK Ok
    modifier onlyOwner {
        // BK Ok
        require(msg.sender == owner);
        // BK Ok
        _;
    }

    // BK Ok - Constructor
    function Owned() public {
        // BK Ok
        owner = msg.sender;
    }
    // BK Ok - Only owner can execute
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    // BK Ok - Only new owner can execute
    function acceptOwnership() public {
        // BK Ok
        require(msg.sender == newOwner);
        // BK Ok - Log event
        OwnershipTransferred(owner, newOwner);
        // BK Ok
        owner = newOwner;
        // BK Ok
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals, minting and
// transferable flag. See:
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
// BK Ok
contract ERC20Token is ERC20Interface, Owned, SafeMath {
    // BK Next 4 Ok
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    // BK Next 2 Ok
    bool public transferable;
    bool public mintable = true;

    // BK Next 2 Ok
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    // BK Next 2 Ok - Events
    event MintingDisabled();
    event TransfersEnabled();

    // BK Ok - Constructor
    function ERC20Token(string _symbol, string _name, uint8 _decimals) public {
        // BK Next 3 Ok
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
    }

    // --- ERC20 standard functions ---
    // BK Ok - Constant function
    function totalSupply() public constant returns (uint) {
        // BK Ok
        return _totalSupply  - balances[address(0)];
    }
    // BK Ok - Constant function
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        // BK Ok
        return balances[tokenOwner];
    }
    // BK Ok
    function transfer(address to, uint tokens) public returns (bool success) {
        // BK Ok
        require(transferable);
        // BK Next 2 Ok
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        // BK Ok - Log event
        Transfer(msg.sender, to, tokens);
        // BK Ok
        return true;
    }
    // BK Ok
    function approve(address spender, uint tokens) public returns (bool success) {
        // BK Ok
        require(transferable);
        // BK Ok
        allowed[msg.sender][spender] = tokens;
        // BK Ok - Log event
        Approval(msg.sender, spender, tokens);
        // BK Ok
        return true;
    }
    // BK Ok
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        // BK Ok
        require(transferable);
        // BK Next 3 Ok
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        // BK Ok - Log event
        Transfer(from, to, tokens);
        // BK Ok
        return true;
    }
    // BK Ok - Constant function
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        // BK Ok
        return allowed[tokenOwner][spender];
    }

    // --- Additions over ERC20 ---
    // BK Ok - Internal function
    function disableMinting() internal {
        // BK Ok
        require(mintable);
        // BK Ok
        mintable = false;
        // BK Ok - Log event
        MintingDisabled();
    }
    // BK Ok - Only owner can execute
    function enableTransfers() public onlyOwner {
        // BK Ok
        require(!transferable);
        // BK Ok
        transferable = true;
        // BK Ok - Log event
        TransfersEnabled();
    }
    // BK Ok - Internal function
    function mint(address tokenOwner, uint tokens) internal {
        // BK Ok
        require(mintable);
        // BK Next 2 Ok
        balances[tokenOwner] = safeAdd(balances[tokenOwner], tokens);
        _totalSupply = safeAdd(_totalSupply, tokens);
        // BK Ok - Log event
        Transfer(address(0), tokenOwner, tokens);
    }
    // BK Ok - Only owner can execute
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        // BK Ok
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}


// ----------------------------------------------------------------------------
// Devery Presale Token Contract
// ----------------------------------------------------------------------------
// BK Ok
contract DeveryPresale is ERC20Token {
    // BK Ok
    address public wallet;
    // 9:00pm, 14 December GMT-5 => 02:00 15 December UTC => 13:00 15 December AEST => 1513303200
    // new Date(1513303200 * 1000).toUTCString() =>  "Fri, 15 Dec 2017 02:00:00 UTC"
    // BK Ok
    uint public constant START_DATE = 1513303200;
    // BK Ok
    bool public closed;
    // BK Ok
    uint public ethMinContribution = 20 ether;
    // BK Ok
    uint public usdCap = 2000000;
    // ETH/USD 8 Dec 2017 11:00 EST => 8 Dec 2017 16:00 UTC => 9 Dec 2017 03:00 AEST => 453.55 from CMC
    // BK Ok
    uint public usdPerKEther = 453550;
    // BK Next 2 Ok
    uint public contributedEth;
    uint public contributedUsd;
    // BK Next 2 Ok
    DeveryPresaleWhitelist public whitelist;
    PICOPSCertifier public picopsCertifier;

    // BK Next 6 Ok - Events
    event EthMinContributionUpdated(uint oldEthMinContribution, uint newEthMinContribution);
    event UsdCapUpdated(uint oldUsdCap, uint newUsdCap);
    event UsdPerKEtherUpdated(uint oldUsdPerKEther, uint newUsdPerKEther);
    event WhitelistUpdated(address indexed oldWhitelist, address indexed newWhitelist);
    event PICOPSCertifierUpdated(address indexed oldPICOPSCertifier, address indexed newPICOPSCertifier);
    event Contributed(address indexed addr, uint ethAmount, uint ethRefund, uint usdAmount, uint contributedEth, uint contributedUsd);

    // BK Ok - Constructor
    function DeveryPresale(address _wallet) public ERC20Token("PREVE", "Presale EVE Tokens", 18) {
        // BK Next 2 Ok
        require(_wallet != address(0));
        wallet = _wallet;
    }
    // BK Ok - Only owner can execute
    function setEthMinContribution(uint _ethMinContribution) public onlyOwner {
        // require(now <= START_DATE);
        // BK Ok - Log event
        EthMinContributionUpdated(ethMinContribution, _ethMinContribution);
        // BK Ok
        ethMinContribution = _ethMinContribution;
    }
    // BK Ok - Only owner can execute 
    function setUsdCap(uint _usdCap) public onlyOwner {
        // require(now <= START_DATE);
        // BK Ok - Log event
        UsdCapUpdated(usdCap, _usdCap);
        // BK Ok
        usdCap = _usdCap;
    } 
    // BK Ok - Only owner can execute
    function setUsdPerKEther(uint _usdPerKEther) public onlyOwner {
        // require(now <= START_DATE);
        // BK Ok - Log event
        UsdPerKEtherUpdated(usdPerKEther, _usdPerKEther);
        // BK Ok
        usdPerKEther = _usdPerKEther;
    }
    // BK Ok - Only owner can execute
    function setWhitelist(address _whitelist) public onlyOwner {
        // require(now <= START_DATE);
        // BK Ok - Log event
        WhitelistUpdated(address(whitelist), _whitelist);
        // BK Ok
        whitelist = DeveryPresaleWhitelist(_whitelist);
    }
    // BK Ok - Only owner can execute
    function setPICOPSCertifier(address _picopsCertifier) public onlyOwner {
        // require(now <= START_DATE);
        // BK Ok - Log event
        PICOPSCertifierUpdated(address(picopsCertifier), _picopsCertifier);
        // BK Ok
        picopsCertifier = PICOPSCertifier(_picopsCertifier);
    }
    // BK Ok - Constant function
    function addressCanContribute(address _addr) public view returns (bool) {
        // BK Ok
        return whitelist.whitelist(_addr) > 0 || picopsCertifier.certified(_addr);
    }
    // BK Ok - View function
    function ethCap() public view returns (uint) {
        // BK Ok
        return usdCap * 10**uint(3 + 18) / usdPerKEther;
    }
    // BK Ok - Only owner can execute
    function closeSale() public onlyOwner {
        // BK Ok
        require(!closed);
        // BK Ok
        closed = true;
        // BK Ok - Call internal function
        disableMinting();
    }
    // BK Ok
    function () public payable {
        // BK Ok
        require(now >= START_DATE);
        // BK Ok
        require(!closed);
        // BK Ok
        require(whitelist.whitelist(msg.sender) > 0 || picopsCertifier.certified(msg.sender));
        // BK Ok
        require(msg.value >= ethMinContribution);
        // BK Ok
        uint ethAmount = msg.value;
        // BK Ok
        uint ethRefund = 0;
        // BK Ok
        if (safeAdd(contributedEth, ethAmount) > ethCap()) {
            // BK Ok
            ethAmount = safeSub(ethCap(), contributedEth);
            // BK Ok
            ethRefund = safeSub(msg.value, ethAmount);
        }
        // BK Ok
        uint usdAmount = ethAmount * usdPerKEther / 10**uint(3 + 18);
        // BK Ok
        contributedEth = safeAdd(contributedEth, ethAmount);
        // BK Ok
        contributedUsd = safeAdd(contributedUsd, usdAmount);
        // BK Ok
        mint(msg.sender, ethAmount);
        // BK Ok
        if (contributedEth >= ethCap()) {
            // BK Ok
            closed = true;
            // BK Ok
            disableMinting();
        }
        // BK Ok
        wallet.transfer(ethAmount);
        // BK Ok - Log event
        Contributed(msg.sender, ethAmount, ethRefund, usdAmount, contributedEth, contributedUsd);
        // BK Ok
        if (ethRefund > 0) {
            // BK Ok
            msg.sender.transfer(ethRefund);
        }
    }
}
```
