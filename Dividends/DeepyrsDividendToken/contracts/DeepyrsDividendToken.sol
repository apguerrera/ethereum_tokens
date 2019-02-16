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
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
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

contract ERC20 is IERC20, Owned {
    using SafeMath for uint256;
    uint256 constant POINTS_PER_WEI = 1e32;

    // ERC20 mintable
    // mapping (address => uint256) private balances_;
    mapping (address => mapping (address => uint256)) private allowed_;
    string public name;
    string public symbol;
    uint256 private totalSupply_;
    uint8 public decimals;

    bool public mintable = true;
    bool public transferable = false;

    // Dividends
    struct Account {
        uint256 balance;
        uint256 lastDividendPoints;
    }
    struct Dividend {
        ERC20 token;
        uint amount;
    }

    Dividend[] internal dividends;
    mapping(address=>Account) public accounts;

    uint256 public totalDividendPoints;
    uint256 public dividendsCollected;
    uint256 public dividendsTotal;

    mapping (address => uint) public creditedPoints;
    mapping (address => uint) public lastPointsPerToken;

    // Events
    event Mint(address indexed to, uint256 amount);
    event MintStarted();
    event MintFinished();
    event TransfersEnabled();
    event TransfersDisabled();
    event DividendReceived(uint time, address indexed sender, uint amount);
    event CollectedDividends(uint time, address indexed account, uint amount);


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
      name = "Deepyr Token";
      symbol = "DEEPYR";
      decimals = 18;
      totalSupply_ = 10000000 * 10**uint(decimals);
      accounts[owner].balance = totalSupply_;
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
      return accounts[_owner].balance;
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
      return _transferFrom(msg.sender, _to, _value );
    }

    function transferFrom(  address _from,  address _to,uint256 _value )  public  returns (bool) {
      require(transferable);
      return _transferFrom(_from, _to, _value );

    }

    function _transferFrom(  address _from,  address _to,uint256 _value )  internal  returns (bool) {
      require(_value <= accounts[_from].balance);
      require(_value <= allowed_[_from][msg.sender]);
      require(_to != address(0));
      _updateCreditedPoints(_from);
      _updateCreditedPoints(_to);
      accounts[_from].balance = accounts[_from].balance.sub(_value);
      accounts[_to].balance = accounts[_to].balance.add(_value);
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
      require(_account != address(0));
      _updateCreditedPoints(_account);
      totalSupply_ = totalSupply_.add(_amount);
      accounts[_account].balance = accounts[_account].balance.add(_amount);
      emit Transfer(address(0), _account, _amount);
    }

    function _burn(address _account, uint256 _amount) internal {
      require(_account != address(0));
      require(_amount <= accounts[_account].balance);
      _updateCreditedPoints(_account);

      totalSupply_ = totalSupply_.sub(_amount);
      accounts[_account].balance = accounts[_account].balance.sub(_amount);
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
        emit CollectedDividends(now, msg.sender, _amount);
        require(msg.sender.call.value(_amount)(""));
    }

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
    function getOwedDividends(address _account) public view returns (uint _amount) {
        return (_getUncreditedPoints(_account) + creditedPoints[_account])/POINTS_PER_WEI;
    }



    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
      return IERC20(tokenAddress).transfer(owner, tokens);
    }

    function () payable external {
        if (msg.value == 0) return;
        uint256 amount = msg.value;

        // POINTS_PER_WEI is 1e32.
        // So, no multiplication overflow unless msg.value > 1e45 wei (1e27 ETH)
        totalDividendPoints += (amount * POINTS_PER_WEI) / totalSupply_;
        dividendsTotal += amount;
        emit DividendReceived(now, msg.sender, amount);
    }

}
