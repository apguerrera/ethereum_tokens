pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// Security Token
//
// Authors:
// * BokkyPooBah / Bok Consulting Pty Ltd
// * Adrian Guerrera / Deepyr Pty Ltd
//
// Oct 20 2018
// ----------------------------------------------------------------------------

// -------------------------------------------------------------------------
// Safe maths
// -------------------------------------------------------------------------
library SafeMath {
  function add(uint a, uint b) internal pure returns (uint c) {
      c = a + b;
      require(c >= a);
  }
  function sub(uint a, uint b) internal pure returns (uint c) {
      require(b <= a);
      c = a - b;
  }
  function mul(uint a, uint b) internal pure returns (uint c) {
      c = a * b;
      require(a == 0 || c / a == b);
  }
  function div(uint a, uint b) internal pure returns (uint c) {
      require(b > 0);
      c = a / b;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}
//--------------------------------------------------------------------------
// Owned contract
//  - BokkyPooBah
// -------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;
    bool private initialised;

    event OwnershipTransferred(address indexed _from, address indexed _to);
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function initOwned(address _owner) internal {
        require(!initialised);
        owner = _owner;
        initialised = true;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
    function transferOwnershipImmediately(address _newOwner) public onlyOwner {
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

// ----------------------------------------------------------------------------
// Maintain a list of operators that are permissioned to execute certain
// functions
//  - BokkyPooBah
// ----------------------------------------------------------------------------

contract Operated is Owned {
    mapping(address => bool) public operators;

    event OperatorAdded(address _operator);
    event OperatorRemoved(address _operator);

    modifier onlyOperator() {
        require(operators[msg.sender] || owner == msg.sender);
        _;
    }

    function initOperated(address _owner) internal {
        initOwned(_owner);
    }
    function addOperator(address _operator) public onlyOwner {
        require(!operators[_operator]);
        operators[_operator] = true;
        emit OperatorAdded(_operator);
    }
    function removeOperator(address _operator) public onlyOwner {
        require(operators[_operator]);
        delete operators[_operator];
        emit OperatorRemoved(_operator);
    }
}



//  @title ERC-1410 Partially Fungible Token Standard
//  @dev See https://github.com/SecurityTokenStandard/EIP-Spec

contract IERC20 {
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    function name() external view returns (string);
    function symbol() external view returns (string);
    function totalSupply() external constant returns (uint);
    function balanceOf(address tokenOwner) external constant returns (uint balance);
    function allowance(address tokenOwner, address spender) external constant returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function mint(address tokenOwner, uint tokens) external returns (bool success);
    // function burn(uint amount, uint tokens) public returns (bool success);


}

// @dev See [ethereum/eips/issues#777](https://github.com/ethereum/eips/issues/777)
// Jordi Baylina [@jbaylina](https://github.com/jbaylina)
// Jacques Dafflon [@jacquesd](https://github.com/jacquesd)
// Thomas Shababi

contract IERC777 is IERC20 {

    function granularity() external view returns (uint);

    function defaultOperators() external view returns (address[]);
    function authorizeOperator(address operator) external;
    function revokeOperator(address operator) external;
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    function send(address to, uint amount, bytes data) external;
    function operatorSend(address from, address to, uint amount, bytes data, bytes operatorData) external;

    function burn(uint amount, bytes data) public;
    function operatorBurn(address from, uint256 amount, bytes data, bytes operatorData) public;
    function operatorMint(address _tokenHolder, uint256 _amount, bytes _holderData, bytes _operatorData) public;

    event Sent(address indexed operator, address indexed from, address to, uint amount, bytes data, bytes operatorData);
    event Minted(address indexed operator, address indexed to, uint amount, bytes data, bytes operatorData);
    event Burned(address indexed operator, address indexed from, uint amount, bytes holderData, bytes operatorData);
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint tokens, address token, bytes data) public;
}


// ----------------------------------------------------------------------------
// MintableToken = ERC20 + symbol + name + decimals + mint + burn
//
// NOTE: This token contract allows the owner to mint and burn tokens for any
// account, and is used for testing
// ----------------------------------------------------------------------------
contract ERC20Token is IERC20,  Owned {
    using SafeMath for uint;

    string _symbol;
    string  _name;
    uint8 _decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() public {

    }

    function symbol() external view returns (string) {
        return _symbol;
    }
    function name() external view returns (string) {
        return _name;
    }
    function decimals() external view returns (uint8) {
        return _decimals;
    }
    function totalSupply() external view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }
    function balanceOf(address tokenOwner) external view returns (uint balance) {
        return balances[tokenOwner];
    }
    function transfer(address to, uint tokens) external returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    function approve(address spender, uint tokens) external returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) external returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    function allowance(address tokenOwner, address spender) external view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }
    function mint(address tokenOwner, uint tokens) external onlyOwner returns (bool success) {
        balances[tokenOwner] = balances[tokenOwner].add(tokens);
        _totalSupply = _totalSupply.add(tokens);
        emit Transfer(address(0), tokenOwner, tokens);
        return true;
    }
    /*
    //duplicate burn.. check where it needs to reside
    function burn(address tokenOwner, uint tokens) public onlyOwner returns (bool success) {
        if (tokens < balances[tokenOwner]) {
            tokens = balances[tokenOwner];
        }
        balances[tokenOwner] = balances[tokenOwner].sub(tokens);
        _totalSupply = _totalSupply.sub(tokens);
        emit Transfer(tokenOwner, address(0), tokens);
        return true;
    }
    */

    function () public payable {
        revert();
    }
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(owner, tokens);
    }
}

//--------------------------------------------------------------------------
// ERC777 = ERC20 + operator functions + granularity
//
// -------------------------------------------------------------------------
contract ERC777Token is ERC20Token, IERC777 {
    using SafeMath for uint;

    uint8 _granularity;

    address[] internal _defaultOperators;
    mapping(address => mapping(address => bool)) _authorized;
    mapping(address => bool) internal _isDefaultOperator;
    mapping(address => mapping(address => bool)) internal _revokedDefaultOperator;

    // constructor (string symbol, string name, uint8 decimals, address tokenOwner, uint initialSupply, uint granularity, address[] defaultOperators ) public {
    constructor (string symbol, string name, uint8 decimals, uint8 granularity, uint _initialSupply ) public {

        initOwned(msg.sender);
        _symbol = symbol;
        _name = name;
        _decimals = decimals;
        _granularity = granularity;

        balances[msg.sender] = _initialSupply;
        _totalSupply = _initialSupply;
        // emit Transfer(address(0), tokenOwner, _totalSupply);  // TO DO: Check how to implement tokenOwner
        emit Transfer(address(0), msg.sender, _initialSupply);

        require(_granularity >= 0);

        _defaultOperators = [msg.sender];
        for (uint i = 0; i < _defaultOperators.length; i++) { _isDefaultOperator[_defaultOperators[i]] = true; }

        // setInterfaceImplementation("ERC777Token", this);
    }


     function granularity() external constant returns (uint) { return _granularity; }

     function requireMultiple(uint256 _amount) internal view {
         require(_amount.div(_granularity).mul(_granularity) == _amount);
     }
     function defaultOperators() external view returns (address[]) { return _defaultOperators; }

     function isOperatorFor(address _operator, address _tokenHolder) external constant returns (bool) {
         return (_operator == _tokenHolder
             || _authorized[_operator][_tokenHolder]
             || (_isDefaultOperator[_operator] && !_revokedDefaultOperator[_operator][_tokenHolder]));
     }

     function authorizeOperator(address _operator) external {
         require(_operator != msg.sender);
         if (_isDefaultOperator[_operator]) {
             _revokedDefaultOperator[_operator][msg.sender] = false;
         } else {
             _authorized[_operator][msg.sender] = true;
         }
         emit AuthorizedOperator(_operator, msg.sender);
     }

     function revokeOperator(address _operator) external {
         require(_operator != msg.sender);
         if (_isDefaultOperator[_operator]) {
             _revokedDefaultOperator[_operator][msg.sender] = true;
         } else {
             _authorized[_operator][msg.sender] = false;
         }
         emit RevokedOperator(_operator, msg.sender);
     }

     function send(address _to, uint _amount, bytes _userData) external {
         doSend(msg.sender, msg.sender, _to, _amount, _userData, "", true);

     }

     function operatorSend(address _from, address _to, uint _amount, bytes _userData, bytes _operatorData) external {
         require(this.isOperatorFor(msg.sender, _from) );  // why do i need to use this..?
         doSend(msg.sender, _from, _to, _amount, _userData, _operatorData, true);
     }

     function doSend(
         address _operator,
         address _from,
         address _to,
         uint _amount,
         bytes _userData,
         bytes _operatorData,
         bool _preventLocking
     ) internal {
         requireMultiple(_amount);
         // callSender(_operator, _from, _to, _amount, _userData, _operatorData);
         require(_to != address(0));          // forbid sending to 0x0 (=burning)
         require(balances[_from] >= _amount); // ensure enough funds
         require(_preventLocking);
         balances[_from] = balances[_from].sub(_amount);
         balances[_to] = balances[_to].add(_amount);
         // callRecipient(_operator, _from, _to, _amount, _userData, _operatorData, _preventLocking);
         emit Sent(_operator, _from, _to, _amount, _userData, _operatorData);
     }


    function doBurn(address _operator, address _tokenHolder, uint256 _amount, bytes _holderData, bytes _operatorData)
        internal
    {
        requireMultiple(_amount);
        require(balances[_tokenHolder] >= _amount);

        balances[_tokenHolder] = balances[_tokenHolder].sub(_amount);
        _totalSupply = _totalSupply.sub(_amount);

        // callSender(_operator, _tokenHolder, 0x0, _amount, _holderData, _operatorData);
        emit Burned(_operator, _tokenHolder, _amount, _holderData, _operatorData);
    }

    function burn(uint256 _amount, bytes _holderData) public {
        doBurn(msg.sender, msg.sender, _amount, _holderData, "");
    }

    function operatorBurn(address _tokenHolder, uint256 _amount, bytes _holderData, bytes _operatorData) public {
        require(this.isOperatorFor(msg.sender, _tokenHolder));
        doBurn(msg.sender, _tokenHolder, _amount, _holderData, _operatorData);
    }

    function doMint(address _operator, address _tokenHolder, uint256 _amount, bytes _holderData, bytes _operatorData)
        internal
    {
        requireMultiple(_amount);
        require(balances[_tokenHolder] >= _amount);

        balances[_tokenHolder] = balances[_tokenHolder].add(_amount);
        _totalSupply = _totalSupply.add(_amount);
        emit Transfer(address(0), _tokenHolder, _amount);

        // callSender(_operator, _tokenHolder, 0x0, _amount, _holderData, _operatorData);
        emit Minted(_operator, _tokenHolder, _amount, _holderData, _operatorData);
    }

    function operatorMint(address _tokenHolder, uint256 _amount, bytes _holderData, bytes _operatorData) public {
      require(this.isOperatorFor(msg.sender, _tokenHolder));
      doMint(msg.sender, _tokenHolder, _amount, _holderData, _operatorData);
    }
}

// set operator to MC
// call exchange on MC
// MC mint tokens
// MC burns tokens
// Operator checks both balances
// Op revokes MC rights


contract DeepyrSecurityTokenOperator {

}

// MC mint tokens
// MC burns tokens
contract DeepyrSecurityTokenConverter {
    /*
    function canConvert (IERC777 _from, IERC777 _to, address _converter) returns (bool success) {
        // check whitelist
        return (whiteList.isInBonusList(from));
    }
    */

    // needs to have this contract as the operator of the 777 tokens
    function convertToken (address _account, IERC777 _from, IERC777 _to, uint _amount, bytes _holderData, bytes _operatorData) public returns (bool success) {
        IERC777 fromToken = IERC777(_from);
        IERC777 toToken = IERC777(_to);

        fromToken.operatorBurn(_account, _amount, _holderData, _operatorData);
        toToken.operatorMint(_account, _amount, _holderData, _operatorData);
        success = true;

    }

    function () public payable {
        revert();
    }

}
