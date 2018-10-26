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



/// @title IERCST Security Token Standard (EIP 1400)
/// @dev See https://github.com/SecurityTokenStandard/EIP-Spec

contract CanSendCodes {
    byte constant TRANSFER_VERIFIED_UNRESTRICTED = 0xA0;                // Transfer Verified - Unrestricted
    byte constant TRANSFER_VERIFIED_ONCHAIN_APPROVAL = 0xA1;            // Transfer Verified - On-Chain approval for restricted token
    byte constant TRANSFER_VERIFIED_OFFCHAIN_APPROVAL = 0xA2;           // Transfer Verified - Off-Chain approval for restricted token
    byte constant TRANSFER_BLOCKED_SENDER_LOCKED_PERIOD = 0xA3;         // Transfer Blocked - Sender lockup period not ended
    byte constant TRANSFER_BLOCKED_SENDER_BALANCE_INSUFFICIENT = 0xA4;  // Transfer Blocked - Sender balance insufficient
    byte constant TRANSFER_BLOCKED_SENDER_NOT_ELIGIBLE = 0xA5;          // Transfer Blocked - Sender not eligible
    byte constant TRANSFER_BLOCKED_RECEIVER_NOT_ELIGIBLE = 0xA6;        // Transfer Blocked - Receiver not eligible
    byte constant TRANSFER_BLOCKED_IDENTITY_RESTRICTION = 0xA7;         // Transfer Blocked - Identity restriction
    byte constant TRANSFER_BLOCKED_TOKEN_RESTRICTION = 0xA8;            // Transfer Blocked - Token restriction
    byte constant TRANSFER_BLOCKED_TOKEN_GRANULARITY = 0xA9;            // Transfer Blocked - Token granularity
}

//  @title ERC-1410 Partially Fungible Token Standard
//  @dev See https://github.com/SecurityTokenStandard/EIP-Spec

interface IERC20 {
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

interface IERC777 is  {

    function granularity() external view returns (uint);

    function defaultOperators() external view returns (address[]);
    function authorizeOperator(address operator) external;
    function revokeOperator(address operator) external;
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    function send(address to, uint amount, bytes data) external;
    function operatorSend(address from, address to, uint amount, bytes data, bytes operatorData) external;

    // function burn(uint amount, bytes data) external;
    // function operatorBurn(address from, uint256 amount, bytes data, bytes operatorData) external;

    event Sent(address indexed operator, address indexed from, address to, uint amount, bytes data, bytes operatorData);
    event Minted(address indexed operator, address indexed to, uint amount, bytes data, bytes operatorData);
    event Burned(address indexed operator, address indexed from, uint amount, bytes holderData, bytes operatorData);
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}


interface IERC1410  {

    function getDefaultTranches(address _tokenHolder) external view returns (bytes32[]);
    function setDefaultTranche(bytes32[] _tranches) external;
    function balanceOfByTranche(bytes32 _tranche, address _tokenHolder) external view returns (uint);
    function sendByTranche(bytes32 _tranche, address _to, uint _amount, bytes _data) external returns (bytes32);
    // function sendByTranches(bytes32[] _tranches, address[] _tos, uint[] _amounts, bytes _data) external returns (bytes32[]);
    function operatorSendByTranche(bytes32 _tranche, address _from, address _to, uint _amount, bytes _data, bytes _operatorData) external returns (bytes32);
    // function operatorSendByTranches(bytes32[] _tranches, address[] _froms, address[] _tos, uint[] _amounts, bytes _data, bytes _operatorData) external returns (bytes32[]);
    function tranchesOf(address _tokenHolder) external view returns (bytes32[]);
    function defaultOperatorsByTranche(bytes32 _tranche) external view returns (address[]);
    function authorizeOperatorByTranche(bytes32 _tranche, address _operator) external;
    function revokeOperatorByTranche(bytes32 _tranche, address _operator) external;
    function isOperatorForTranche(bytes32 _tranche, address _operator, address _tokenHolder) external view returns (bool);
    // function redeemByTranche(bytes32 _tranche, uint _amount, bytes _data) external;
    // function operatorRedeemByTranche(bytes32 _tranche, address _tokenHolder, uint _amount, bytes _operatorData) external;

    event SentByTranche(
        bytes32 fromTranche,
        bytes32 toTranche,
        address indexed operator,
        address indexed from,
        address indexed to,
        uint amount,
        bytes data,
        bytes operatorData
    );
    event AuthorizedOperatorByTranche(bytes32 indexed tranche, address indexed operator, address indexed tokenHolder);
    event RevokedOperatorByTranche(bytes32 indexed tranche, address indexed operator, address indexed tokenHolder);
    event BurnedByTranche(bytes32 indexed tranche, address indexed operator, address indexed from, uint amount, bytes operatorData);
}

/*
interface IERCST {
    function getDocument(bytes32 name) external view returns (string _uri, bytes32 _documentHash);
    function setDocument(bytes32 name, string _uri, bytes32 _documentHash) external;
    function issuable() external view returns (bool);
    function canSend(address _from, address _to, bytes32 _tranche, uint _amount, bytes _data) external view returns (byte, bytes32, bytes32);
    function issueByTranche(bytes32 _tranche, address _tokenHolder, uint _amount, bytes _data) external;
    event IssuedByTranche(bytes32 indexed tranche, address indexed operator, address indexed to, uint amount, bytes data, bytes operatorData);
}

*/


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

    function symbol() public view returns (string) {
        return _symbol;
    }
    function name() public view returns (string) {
        return _name;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }
    function mint(address tokenOwner, uint tokens) public onlyOwner returns (bool success) {
        balances[tokenOwner] = balances[tokenOwner].add(tokens);
        _totalSupply = _totalSupply.add(tokens);
        emit Transfer(address(0), tokenOwner, tokens);
        return true;
    }
    function burn(address tokenOwner, uint tokens) public onlyOwner returns (bool success) {
        if (tokens < balances[tokenOwner]) {
            tokens = balances[tokenOwner];
        }
        balances[tokenOwner] = balances[tokenOwner].sub(tokens);
        _totalSupply = _totalSupply.sub(tokens);
        emit Transfer(tokenOwner, address(0), tokens);
        return true;
    }
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

    uint _granularity;

    address[] internal _defaultOperators;
    mapping(address => mapping(address => bool)) _authorized;
    mapping(address => bool) internal _isDefaultOperator;
    mapping(address => mapping(address => bool)) internal _revokedDefaultOperator;

    // constructor (string symbol, string name, uint8 decimals, address tokenOwner, uint initialSupply, uint granularity, address[] defaultOperators ) public {
    constructor ( ) public {

        initOwned(msg.sender);
        _symbol = "symbol";
        _name = "name";
        _decimals = 18; // decimals;
        _granularity = 1; // granularity;

        balances[msg.sender] = 1000;  //initialSupply;
        _totalSupply =  1000; // initialSupply;
        // emit Transfer(address(0), tokenOwner, _totalSupply);
        emit Transfer(address(0), msg.sender, _totalSupply);

        require(_granularity >= 0);

        _defaultOperators = [msg.sender];
        for (uint i = 0; i < _defaultOperators.length; i++) { _isDefaultOperator[_defaultOperators[i]] = true; }

        // setInterfaceImplementation("ERC777Token", this);
    }


     function granularity() public constant returns (uint) { return _granularity; }

     function requireMultiple(uint256 _amount) internal view {
         require(_amount.div(_granularity).mul(_granularity) == _amount);
     }
     function defaultOperators() public view returns (address[]) { return _defaultOperators; }

     function isOperatorFor(address _operator, address _tokenHolder) public constant returns (bool) {
         return (_operator == _tokenHolder
             || _authorized[_operator][_tokenHolder]
             || (_isDefaultOperator[_operator] && !_revokedDefaultOperator[_operator][_tokenHolder]));
     }

     function authorizeOperator(address _operator) public {
         require(_operator != msg.sender);
         if (_isDefaultOperator[_operator]) {
             _revokedDefaultOperator[_operator][msg.sender] = false;
         } else {
             _authorized[_operator][msg.sender] = true;
         }
         emit AuthorizedOperator(_operator, msg.sender);
     }

     function revokeOperator(address _operator) public {
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
         require(isOperatorFor(msg.sender, _from));
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

 //--------------------------------------------------------------------------
 // ERC777 = ERC20 + operator functions + granularity
 //
 // -------------------------------------------------------------------------
 contract ERC1410Token is ERC777Token {
    using SafeMath for uint;

    bytes[] public tranches;
    mapping(bytes32 => address) trancheAddress;

    mapping(address => bytes32[]) defaultTranches;
    mapping(address => bytes32[]) holderTranches;

     function getDefaultTranches(address _tokenHolder) external view returns (bytes32[]) {
          return defaultTranches[_tokenHolder];
     }

     function setDefaultTranche(bytes32[] _tranches) external {
          defaultTranches[msg.sender] = _tranches;
     }

     function balanceOfByTranche(bytes32 _tranche, address _tokenHolder) external view returns (uint) {
          token = IERC777(trancheAddress[_tranche]);
          return token.balanceOf(_tokenHolder);
     }

     function sendByTranche(bytes32 _tranche, address _to, uint _amount, bytes _data) external returns (bytes32) {
          token = IERC777(trancheAddress[_tranche]);
          token.send(_to, _amount, _data);
          return _tranche;
     }

     function operatorSendByTranche(bytes32 _tranche, address _from, address _to, uint _amount, bytes _data, bytes _operatorData) external returns (bytes32) {
          token = IERC777(trancheAddress[_tranche]);
          token.operatorSend(address _from, address _to, uint _amount, bytes _data, bytes _operatorData);
          return _tranche;
     }

     function tranchesOf(address _tokenHolder) external view returns (bytes32[]) {
          return holderTranches[_tokenHolder];
     }
     function defaultOperatorsByTranche(bytes32 _tranche) external view returns (address[]) {
        token = IERC777(trancheAddress[_tranche]);
        return token.defaultOperators();
     }

     function authorizeOperatorByTranche(bytes32 _tranche, address _operator) external {
          require(_operator != msg.sender);
          token = IERC777(trancheAddress[_tranche]);
          token.authorizeOperator(_operator);
     }

     function revokeOperatorByTranche(bytes32 _tranche, address _operator) external {
          require(_operator != msg.sender);
          token = IERC777(trancheAddress[_tranche]);
          token.revokeOperator(_operator);
     }

     function isOperatorForTranche(bytes32 _tranche, address _operator, address _tokenHolder) external view returns (bool) {
           token = IERC777(trancheAddress[_tranche]);
           return token.isOperatorFor(_operator, _tokenHolder);
     }



//------------ To Do List -----------------------------

//  [] add events
//  [] finish interface
/*
     function sendByTranches(bytes32[] _tranches, address[] _tos, uint[] _amounts, bytes _data) external returns (bytes32[]);
     function operatorSendByTranches(bytes32[] _tranches, address[] _froms, address[] _tos, uint[] _amounts, bytes _data, bytes _operatorData) external returns (bytes32[]);

     function redeemByTranche(bytes32 _tranche, uint _amount, bytes _data) external;
     function operatorRedeemByTranche(bytes32 _tranche, address _tokenHolder, uint _amount, bytes _operatorData) external;
*/

}

contract DeepyrSecurityToken is ERC1410Token {
     using SafeMath for uint;

     struct Document {
       string name
       , string uri
       , bytes32 documentHash
     }

     Document[] public documents;

    function getDocument(bytes32 name) external view returns (string _uri, bytes32 _documentHash) {
          Document document = documents[name];
          return (document.uri, document.documentHash);
    }
    function setDocument(bytes32 name, string _uri, bytes32 _documentHash) external {
      documents = Document(name, _uri, _documentHash);
    }

//------------ To Do List -----------------------------


    function setDocument(bytes32 name, string _uri, bytes32 _documentHash) external;
    // If a token returns FALSE for isIssuable() then it MUST always return FALSE in the future.
    function issuable() external view returns (bool);
    function canSend(address _from, address _to, bytes32 _tranche, uint _amount, bytes _data) external view returns (byte, bytes32, bytes32);
    function issueByTranche(bytes32 _tranche, address _tokenHolder, uint _amount, bytes _data) external;

}
