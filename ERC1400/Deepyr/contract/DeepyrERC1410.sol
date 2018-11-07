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

    // function burn(uint amount, bytes data) external;
    // function operatorBurn(address from, uint256 amount, bytes data, bytes operatorData) external;

    event Sent(address indexed operator, address indexed from, address to, uint amount, bytes data, bytes operatorData);
    event Minted(address indexed operator, address indexed to, uint amount, bytes data, bytes operatorData);
    event Burned(address indexed operator, address indexed from, uint amount, bytes holderData, bytes operatorData);
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}


contract IERC1410  {

    function getDefaultTranche(address _tokenHolder) external view returns (bytes32);
    function setDefaultTranche(bytes32 _tranche) public;
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


contract IERCST {
    function getDocument(bytes32 name) external view returns (string _uri, bytes32 _documentHash);
    function setDocument(bytes32 name, string _uri, bytes32 _documentHash) external;
    function issuable() external view returns (bool);
    function canSend(address _from, address _to, bytes32 _tranche, uint _amount, bytes _data) external view returns (byte, bytes32, bytes32);
    function issueByTranche(bytes32 _tranche, address _tokenHolder, uint _amount, bytes _data) external;
    event IssuedByTranche(bytes32 indexed tranche, address indexed operator, address indexed to, uint amount, bytes data, bytes operatorData);
}

// Security token conversion contract

contract ISTCONV {
  function canConvert(bytes32 _from, bytes32 _to, uint amount, bytes _data) external view returns (bool success);
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
         // require( isOperatorFor(msg.sender, _from) );  // NEED TO FIX, require is failing to compile.
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

}

 //--------------------------------------------------------------------------
 // ERC777 = ERC20 + operator functions + granularity
 //
 // -------------------------------------------------------------------------
 contract ERC1410Token is IERC1410 {
    using SafeMath for uint;

    bytes[] public tranches;
    mapping(bytes32 => address) public trancheAddress;

    mapping(address => bytes32) defaultTranche;
    mapping(address => bytes32[]) holderTranches;

     function getDefaultTranche(address _tokenHolder) external view returns (bytes32) {
          return defaultTranche[_tokenHolder];
     }

     function setDefaultTranche(bytes32 _tranche) public {
          defaultTranche[msg.sender] = _tranche;
     }

     function balanceOfByTranche(bytes32 _tranche, address _tokenHolder) external view returns (uint) {
          return IERC777(trancheAddress[_tranche]).balanceOf(_tokenHolder);
     }

     function sendByTranche(bytes32 _tranche, address _to, uint _amount, bytes _data) external returns (bytes32) {
          IERC777(trancheAddress[_tranche]).send(_to, _amount, _data);
          return _tranche;
     }

     function operatorSendByTranche(bytes32 _tranche, address _from, address _to, uint _amount, bytes _data, bytes _operatorData) external returns (bytes32) {
          IERC777(trancheAddress[_tranche]).operatorSend(_from,_to,_amount,_data,_operatorData);
          return _tranche;
     }

     function tranchesOf(address _tokenHolder) external view returns (bytes32[]) {
          return holderTranches[_tokenHolder];
     }
     function defaultOperatorsByTranche(bytes32 _tranche) external view returns (address[]) {
        return IERC777(trancheAddress[_tranche]).defaultOperators();
     }

     function authorizeOperatorByTranche(bytes32 _tranche, address _operator) external {
          require(_operator != msg.sender);
          IERC777(trancheAddress[_tranche]).authorizeOperator(_operator);
     }

     function revokeOperatorByTranche(bytes32 _tranche, address _operator) external {
          require(_operator != msg.sender);
          IERC777(trancheAddress[_tranche]).revokeOperator(_operator);
     }

     function isOperatorForTranche(bytes32 _tranche, address _operator, address _tokenHolder) external view returns (bool) {
           return IERC777(trancheAddress[_tranche]).isOperatorFor(_operator, _tokenHolder);
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

contract WhiteListInterface {
    function isInWhiteList(bytes32 tranche, address account) public view returns (bool);
}

// ----------------------------------------------------------------------------
// Bonus List - on list or not
// - BokkyPooBah
// ----------------------------------------------------------------------------
contract WhiteList is WhiteListInterface, Operated {

    mapping(bytes32 => mapping(address => bool)) whiteList;

    event AccountListed(bytes32 indexed tranche, address indexed account, bool status);

    constructor() public {
        initOperated(msg.sender);
    }

    function isInWhiteList(bytes32 tranche, address account) public view returns (bool) {
        return whiteList[tranche][account];
    }

    function add(bytes32 tranche, address[] accounts) public onlyOperator {
        require(accounts.length != 0);
        for (uint i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0));
            if (!whiteList[tranche][accounts[i]]) {
                whiteList[tranche][accounts[i]] = true;
                emit AccountListed(tranche, accounts[i], true);
            }
        }
    }
    function remove(bytes32 tranche, address[] accounts) public onlyOperator {
        require(accounts.length != 0);
        for (uint i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0));
            if (whiteList[tranche][accounts[i]]) {
                delete whiteList[tranche][accounts[i]];
                emit AccountListed(tranche, accounts[i], false);
            }
        }
    }
}

/*
// work in progress
contract DeepyrSecurityTokenConverter {
    function canConvert (IERC777 _from, IERC777 _to, address _converter) return (bool success) {
        // check whitelist
        return (whiteList.isInBonusList(from));
    }

    function convertToken (IERC777 _from, IERC777 _to, address _converter) returns (bool success);
        // can convert
        // mint and burn tranches
        //
}
*/

// work in progress
contract DeepyrSecurityToken is Owned, ERC1410Token {
     using SafeMath for uint;

     uint private constant TENPOW18 = 10 ** 18;
     IERC777 public baseToken;
     WhiteListInterface public whiteList;

     struct Checkpoint {
       uint128 fromBlock;
       uint128 value;
     }
     struct Document {
        string uri;
        bytes32 documentHash;
     }

     Checkpoint[] totalSupplyHistory;
    // Document[] public documents;
     mapping(bytes32 => Document ) documents;

     mapping(bytes32 => mapping(bytes32 => address)) trancheConversions; // address[] an array of conversions

     constructor(address _baseToken, address _whiteList) public {
       require(_baseToken != address(0) && _whiteList != address(0));
       initOwned(msg.sender);
       baseToken = IERC777(_baseToken);
       whiteList = WhiteListInterface(_whiteList);
       (bytes32 tranche, bool success) = addTranche(baseToken);
       if (success) {
         setDefaultTranche(tranche);
       }
       // add to totalSupplyHistory { block.number, baseToken.totalSupply(); }
     }
    /* functions overloaded, please investigate which to keep
     function symbol() public view returns (string _symbol) {
         _symbol = baseToken.symbol();
     }
     function name() public view returns (string _name) {
         _name = baseToken.name();
     }
     */

    function getDocument(bytes32 _name) external view returns (string _uri, bytes32 _documentHash) {
          Document memory document = documents[_name];
          return (document.uri, document.documentHash);
    }
    function setDocument(bytes32 _name, string _uri, bytes32 _documentHash) external {
      documents[_name] = Document(_uri, _documentHash);
    }


    function totalSupply() public constant returns (uint) {
      return totalSupplyHistoryAt(block.number);
    }
    function totalSupplyHistoryAt (uint _blockNumber) public constant returns (uint) {
      if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
        return 0;
      } else {
        return getValueAt(totalSupplyHistory, _blockNumber);
      }
    }

    function getValueAt (Checkpoint[] storage checkpoints, uint _block) constant internal returns (uint ) {
      if (checkpoints.length == 0 || (_block < checkpoints[0].fromBlock)) return 0;
      if (_block >= checkpoints[checkpoints.length-1].fromBlock) {
          checkpoints[checkpoints.length-1].value;
      }
      // binary search of the value in the array
      uint min = 0;
      uint max = checkpoints.length-1;
      while (max > min) {
          uint mid = (max + min + 1)/2;
          if (checkpoints[mid].fromBlock <= _block) {
            min = mid;
          } else {
              max = mid - 1;
          }
      }
      return checkpoints[min].value;
    }


    function addTranche(address _token) public returns (bytes32 tranche, bool success) {
      tranche = keccak256(_token);
      trancheAddress[tranche] = _token;
      success = true;
    }

    /*
    // not working with token creation :(
    function addNewTranche(string tokenSymbol, string tokenName, uint8  tokenDecimals, uint8 granularity, uint initialSupply ) public  returns ( bool success)  {
        // address _token = new ERC777Token(tokenSymbol, tokenName, tokenDecimals, granularity, initialSupply);
        // address _token = new ERC777Token("TEST", "Test Token", 18, 1, 2000000);

        // bytes32 tranche = keccak256(_token);
        // trancheAddress[tranche] = _token;
        success = true;
      }
    */

    // conversion should be from an internal function which calls a mint and burn on the 777 tokens and a custom event
    // conversion could also act like a proxy that opperates on the data
    function convertTranche(bytes32 from, bytes32 to, uint amount, bytes _userData) external {
        require(trancheConversions[from][to] != address(0) && trancheAddress[from] != address(0) && trancheAddress[to] != address(0) && amount > 0 );
        address convertAddress = trancheConversions[from][to];
        IERC777 fromToken = IERC777(trancheAddress[from]);
        IERC777 toToken = IERC777(trancheAddress[to]);
        // DeepyrSecurityTokenConverter.convertToken();

    }

    function canSend(address _from, address _to, bytes32 _tranche, uint _amount, bytes _data) external view returns (byte, bytes32, bytes32) {
        IERC777 token = IERC777(trancheAddress[_tranche]);
    }



    // footer functions
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(owner, tokens);
    }

    function () public payable {
        revert();
    }

//------------ To Do List -----------------------------


    // If a token returns FALSE for isIssuable() then it MUST always return FALSE in the future.
    // function issuable() external view returns (bool);
    // function canSend(address _from, address _to, bytes32 _tranche, uint _amount, bytes _data) external view returns (byte, bytes32, bytes32);
    // function issueByTranche(bytes32 _tranche, address _tokenHolder, uint _amount, bytes _data) external;

//-------- Bonus list ---------------

    // function lockTokens();   // locking up tranch tokens for collateral

}



// work in progress
// creates security tokens from calling
contract DeepyrSecurityTokenFactory is Owned {

      // ------------------------------------------------------------------------
      // Internal data
      // ------------------------------------------------------------------------
      DeepyrSecurityToken[] public deployedTokens;
      mapping(address => bool) _verify;

      // ------------------------------------------------------------------------
      // Event
      // ------------------------------------------------------------------------
      event SecurityTokenListing(address indexed securityAddress,address indexed tokenAddress, address whiteListAddress );

    // ------------------------------------------------------------------------
    // Anyone can call this method to verify whether the securityToken contract at
    // the specified address was deployed using this factory
    //
    // Parameters:
    //   tokenContract  the security contract address
    //
    // Return values:
    //   valid          did this SecurityTokenFactory create the SecurityToken contract?
    //   decimals       number of decimal places for the token contract
    //   initialSupply  the token initial supply
    //   mintable       is the token mintable after deployment?
    //   transferable   are the tokens transferable after deployment?
    // ------------------------------------------------------------------------
    function verify(address tokenContract) public view returns (
        bool    valid,
        address owner
        // uint    decimals,
        // bool    mintable,
        // bool    transferable
    ) {
        valid = _verify[tokenContract];
        if (valid) {
            //
            DeepyrSecurityToken t = DeepyrSecurityToken(tokenContract);
            owner        = t.owner();
            // decimals     = t.decimals();
            // mintable     = t.mintable();
            // transferable = t.transferable();
        }
    }


    // not finished
    function deploySecurityToken (
          string tokenSymbol
          , string tokenName
          , uint8 tokenDecimals
          , uint8 granularity
          , uint256 initialSupply
          // need to fix return
      ) public returns (address securityToken, address token, address whitelist) {

        // need to redo with ERC777 constructor
        token = new ERC777Token(tokenSymbol, tokenName, tokenDecimals, granularity,initialSupply );
        // need to fix this
        whitelist = new WhiteList();
        securityToken = new DeepyrSecurityToken(token, whitelist);
        _verify[address(securityToken)] = true;

        deployedTokens.push(DeepyrSecurityToken(securityToken));

        emit SecurityTokenListing(address(securityToken), address(token), address(whitelist));
    }

    function numberOfDeployedTokens() public view returns (uint) {
        return deployedTokens.length;
    }

    // footer functions
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(owner, tokens);
    }

    function () public payable {
        revert();
    }


}
