pragma solidity ^0.4.25;

// ----------------------------------------------------------------------------
// 'DEEPYR' token contract
//
// Symbol      : DEEPYR
// Name        : Deepyr Token
// Total supply: 10,000,000.000000000000000000
// Decimals    : 18
//
// Enjoy.
//
// (c) Adrian Guerrera / Deepyr Pty Ltd 2018. The MIT Licence.
//
// Code borrowed from various mentioned and from contracts
// (c) BokkyPooBah / Bok Consulting Pty Ltd 2018. The MIT Licence.
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
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


library Snapshotable {
  struct Uint {
      uint[] snapshots;
  }
  function lastEntry(Uint storage self) internal view returns (uint key, uint value) {
    uint packed = last(self);
    return (toKey(packed), toValue(packed));
  }

  function lastKey(Uint storage self) internal view returns (uint) {
    return toKey(last(self));
  }

  function lastValue(Uint storage self) internal view returns (uint) {
    return toValue(last(self));
  }

  function count(Uint storage self) internal view returns (uint) {
    return self.snapshots.length;
  }

  function entryAt(Uint storage self, uint index) internal view returns (uint key, uint val) {
    uint packed = self.snapshots[index];
    return (toKey(packed), toValue(packed));
  }

  function keyAt(Uint storage self, uint index) internal view returns (uint key) {
    return toKey(self.snapshots[index]);
  }

  function valueAt(Uint storage self, uint index) internal view returns (uint val) {
    return toValue(self.snapshots[index]);
  }

  function scanForKeyBefore(Uint storage self, uint maxKey, uint start) internal view returns (uint val, uint index) {
    uint end = count(self);
    index = start;
    while (index + 1 < end && keyAt(self, index + 1) <= maxKey) {
      index++;
    }
    return (valueAt(self, index), index);
  }

  function reset(Uint storage self, uint key) internal {
    reset(self, key, lastValue(self));
  }

  function reset(Uint storage self, uint key, uint value) internal {
    self.snapshots.length = 1;
    self.snapshots[0] = entry(key, value);
  }

  function increment(Uint storage self, uint key, uint incr) internal {
    uint last = self.snapshots.length;
    if (last == 0) {
      self.snapshots.push(entry(key, incr));
    } else {
      last--;
      uint packed = self.snapshots[last];
      if (toKey(packed) == key) {
        self.snapshots[last] = packed + incr;
      } else {
        self.snapshots.push(entry(key, packed + incr));
      }
    }
  }
  function decrement(Uint storage self, uint key, uint decr) internal {
    uint last = self.snapshots.length;
    require(last > 0);
    last--;
    uint packed = self.snapshots[last];
    require(toValue(packed) >= decr);
    if (toKey(packed) == key) {
      self.snapshots[last] = packed - decr;
    } else {
      self.snapshots.push(entry(key, packed - decr));
    }
  }
  function last(Uint storage self) private view returns (uint) {
    if (self.snapshots.length == 0) {
      return 0;
    } else {
      return self.snapshots[self.snapshots.length-1];
    }
  }

  uint internal constant SHIFT_FACTOR = 2**(256 - 64); // 64 bits of index value
  function toKey(uint packed) private pure returns (uint) {
    return packed / SHIFT_FACTOR;
  }
  function toValue(uint packed) private pure returns (uint) {
    return packed & (SHIFT_FACTOR - 1);
  }
  function entry(uint key, uint value) private pure returns (uint) {
    return (key * SHIFT_FACTOR) | (value & (SHIFT_FACTOR - 1));
  }
}

contract UsingSnapshotable {
  using Snapshotable for Snapshotable.Uint;
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _who) external view returns (uint256);
    function allowance(address _owner, address _spender)  external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value)  external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value)  external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value  );
    event Approval(address indexed owner, address indexed spender, uint256 value  );
}

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
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
}

// ----------------------------------------------------------------------------
// Implementation of the basic standard token.
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
// ----------------------------------------------------------------------------

contract DividendToken is IERC20, UsingSnapshotable,  Owned {
    using SafeMath for uint256;
    uint256 constant POINTS_PER_WEI = 1e32;

    // ERC20 mintable
    mapping (address => uint256) private balances_;
    mapping (address => mapping (address => uint256)) private allowed_;
    string public name;
    string public symbol;
    uint256 private totalSupply_;
    uint8 public decimals;

    bool public mintable = true;
    bool public transferable = false;

    // Dividends
    struct Account {
        uint balance;
        uint lastDividendPoints;
    }
    struct Dividend {
        IERC20 token;
        uint amount;
    }

    Dividend[] internal dividends;
    mapping(address=>Account) public accounts;
    uint256 public totalDividendPoints;
    uint256 public dividendsCollected;
    uint256 public dividendsTotal;
    uint256 public ethDust;

    mapping (address => uint) public creditedPoints;
    mapping (address => mapping (address => uint)) public creditedTokens;
    mapping (address => uint) public lastPointsPerToken;
    // might want to add something to limit to X number of unique tokens for gas

    // snapshotting
    mapping(address => Snapshotable.Uint) internal balanceHistories;

    // Events
    event Mint(address indexed to, uint256 amount);
    event MintStarted();
    event MintFinished();
    event TransfersEnabled();
    event TransfersDisabled();
    event DividendReceived(uint time, address indexed sender, uint amount);
    event DividendIssued(IERC20 indexed token, uint amount);
    event CollectedDividends(uint time, address indexed account,IERC20 indexed token,uint amount);


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
      name = "Deepyr Token";
      symbol = "DEEPYR";
      decimals = 18;
      totalSupply_ = 10000000 * 10**uint(decimals);
      balances_[owner] = totalSupply_;
      emit Transfer(address(0), owner, totalSupply_);
    }

    modifier canMint() {
      require(mintable);
      _;
    }

    // ------------------------------------------------------------------------
    // ERC20 Functions
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint256) {
      return totalSupply_;
    }

    function balanceOf(address _owner) public view returns (uint256) {
      return balances_[_owner];
    }

    function allowance(  address _owner,  address _spender )  public  view  returns (uint256) {
      return allowed_[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
      require(transferable);
      allowed_[msg.sender][_spender] = _value;
      emit Approval(msg.sender, _spender, _value);
      return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
      require(transferable);
      return _transfer(msg.sender, _to, _value );
    }

    function transferFrom(  address _from,  address _to,uint256 _value )  public  returns (bool) {
      require(transferable);
      return _transfer(_from, _to, _value );

    }

    function _transfer(  address _from,  address _to,uint256 _value )  internal  returns (bool) {
      require(_value <= balances_[_from]);
      require(_value <= allowed_[_from][msg.sender]);
      require(_to != address(0));
      _updateCreditedPoints(_from);
      _updateCreditedPoints(_to);
      balances_[_from] = balances_[_from].sub(_value);
      balances_[_to] = balances_[_to].add(_value);
      allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(_value);
      emit Transfer(_from, _to, _value);
      return true;
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    */
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
      allowed_[msg.sender][_spender] = (allowed_[msg.sender][_spender].add(_addedValue));
      emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
      return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
      uint256 oldValue = allowed_[msg.sender][_spender];
      if (_subtractedValue >= oldValue) {
        allowed_[msg.sender][_spender] = 0;
      } else {
        allowed_[msg.sender][_spender] = oldValue.sub(_subtractedValue);
      }
      emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
      return true;
    }

    // ------------------------------------------------------------------------
    // Mint & Burn functions, both interrnal and external
    // ------------------------------------------------------------------------
    function _mint(address _account, uint256 _amount) internal {
      require(_account != 0);
      _updateCreditedPoints(_account);
      totalSupply_ = totalSupply_.add(_amount);
      balances_[_account] = balances_[_account].add(_amount);
      emit Transfer(address(0), _account, _amount);
    }

    function _burn(address _account, uint256 _amount) internal {
      require(_account != 0);
      require(_amount <= balances_[_account]);
      _updateCreditedPoints(_account);

      totalSupply_ = totalSupply_.sub(_amount);
      balances_[_account] = balances_[_account].sub(_amount);
      emit Transfer(_account, address(0), _amount);
    }

    function _burnFrom(address _account, uint256 _amount) internal {
      require(_amount <= allowed_[_account][msg.sender]);
      allowed_[_account][msg.sender] = allowed_[_account][msg.sender].sub(_amount);
      _burn(_account, _amount);
    }

    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
      _mint(_to, _amount);
      emit Mint(_to, _amount);
      return true;
    }

    function burn(uint256 _value)  public {
      _burn(msg.sender, _value);
    }

    function burnFrom(address _from, uint256 _value) public {
      _burnFrom(_from, _value);
    }

    // ------------------------------------------------------------------------
    // Safety to start and stop minting new tokens.
    // ------------------------------------------------------------------------
    function startMinting() public onlyOwner returns (bool) {
      mintable = true;
      emit MintStarted();
      return true;
    }

    function finishMinting() public onlyOwner canMint returns (bool) {
      mintable = false;
      emit MintFinished();
      return true;
    }

    // ------------------------------------------------------------------------
    // Safety to stop token transfers
    // ------------------------------------------------------------------------
    function enableTransfers() public onlyOwner {
      require(!transferable);
      transferable = true;
      emit TransfersEnabled();
    }

    function disableTransfers() public onlyOwner {
      require(transferable);
      transferable = false;
      emit TransfersDisabled();
    }

    // ------------------------------------------------------------------------
    // Dividend functions
    // ------------------------------------------------------------------------
    // Calculate amount of dividends owed in wei
    function dividendsOwing(address account) public view returns(uint256) {   // public for testing, was originally private
      uint256 newDividendPoints = totalDividendPoints - accounts[account].lastDividendPoints;
      return (accounts[account].balance * newDividendPoints) / POINTS_PER_WEI;
    }

    // Updates creditedPoints, sends all wei to the owner
    function collectOwedDividends()
        public
        returns (uint _amount)
    {
        // update creditedPoints, store amount, and zero it.
        _updateCreditedPoints(msg.sender);
        _amount = creditedPoints[msg.sender] / POINTS_PER_WEI;
        creditedPoints[msg.sender] = 0;
        dividendsCollected += _amount;
        emit CollectedDividends(now, msg.sender, IERC20(0x0), _amount);
        require(msg.sender.call.value(_amount)());
    }
    /*  needs to be rewritten to collect only DAI and ETH
    // maybe even my old eth to dai converter
    function collectOwedTokenDividends (IERC20 token) public {
        // Snapshotable.Uint storage balanceHistory = balanceHistories[msg.sender];
        // uint256 firstEligibleDividend = balanceHistory.keyAt(0);

         _updateCreditedPoints(msg.sender);
        uint256 _amount = creditedTokens[token][msg.sender] / POINTS_PER_WEI;
        creditedTokens[token][msg.sender] = 0; // reset needs to be generalised for tokens
        if (address(token) == 0x0) {
            require(msg.sender.call.value(_amount)());
        } else if (address(token) == 0x123) {  // Dai contract
            require(token.transfer(msg.sender, _amount));
        } else {
            require(msg.sender.call.value(_amount)());
        }
        emit CollectedDividends(now, msg.sender,token, _amount);
      }
    */

    // Credits _account with whatever dividend points they haven't yet been credited.
    //  This needs to be called before any user's balance changes to ensure their
    //  "lastPointsPerToken" credits their current balance, and not an altered one.
    function _updateCreditedPoints(address _account)  private {
        creditedPoints[_account] += _getUncreditedPoints(_account);
        lastPointsPerToken[_account] = totalDividendPoints;
    }

    // For a given account, returns how many Wei they haven't yet been credited.
    function _getUncreditedPoints(address _account) private view returns (uint _amount) {
        uint _pointsPerToken = totalDividendPoints - lastPointsPerToken[_account];
        // The upper bound on this number is:
        //   ((1e32 * TOTAL_DIVIDEND_AMT) / totalSupply) * balances[_account]
        // Since totalSupply >= balances[_account], this will overflow only if
        //   TOTAL_DIVIDEND_AMT is around 1e45 wei. Not ever going to happen.
        return _pointsPerToken * balanceOf(_account);
    }

    // Returns how many wei a call to .collectOwedDividends() would transfer.
    function getOwedDividends(address _account) public constant returns (uint _amount) {
        return (_getUncreditedPoints(_account) + creditedPoints[_account])/POINTS_PER_WEI;
    }

    function sweepDust() public onlyOwner {
        uint amount = ethDust;
        ethDust = 0;
        require(transfer(msg.sender, amount));
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
      return IERC20(tokenAddress).transfer(owner, tokens);
    }

    // dividend in different tokens
  function dividend(IERC20 token, uint amount) public onlyOwner {
    // since we wont give this out, don't transfer it in and decrement the dividend amount
    amount -= amount % totalSupply();
    require(token.transferFrom(msg.sender, address(this), amount));
    dividends.push(Dividend(token, amount));
    emit DividendIssued(token, amount);
    emit DividendReceived(now, msg.sender, amount);

  }


    function () payable public {
        if (msg.value == 0) return;
        uint256 dust = msg.value % totalSupply();
        uint256 amount = msg.value - dust;
        ethDust += dust;
        // POINTS_PER_WEI is 1e32.
        // So, no multiplication overflow unless msg.value > 1e45 wei (1e27 ETH)
        dividends.push(Dividend(IERC20(0x0), amount));

        totalDividendPoints += (amount * POINTS_PER_WEI) / totalSupply();
        dividendsTotal += amount;
        emit DividendReceived(now, msg.sender, amount);
        emit DividendIssued(IERC20(0x0), amount);

    }

}
