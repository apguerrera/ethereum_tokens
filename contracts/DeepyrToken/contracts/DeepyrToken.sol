pragma solidity ^0.4.24;


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


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20, Owned {
  using SafeMath for uint256;

  mapping (address => uint256) private balances_;
  mapping (address => mapping (address => uint256)) private allowed_;
  uint256 private totalSupply_;

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return balances_[_owner];
  }

  function allowance(  address _owner,  address _spender )  public  view  returns (uint256) {
    return allowed_[_owner][_spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances_[msg.sender]);
    require(_to != address(0));

    balances_[msg.sender] = balances_[msg.sender].sub(_value);
    balances_[_to] = balances_[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed_[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(  address _from,  address _to,uint256 _value )  public  returns (bool) {
    require(_value <= balances_[_from]);
    require(_value <= allowed_[_from][msg.sender]);
    require(_to != address(0));

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
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed_[msg.sender][_spender] = (
      allowed_[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed_[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed_[msg.sender][_spender] = 0;
    } else {
      allowed_[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param _account The account that will receive the created tokens.
   * @param _amount The amount that will be created.
   */
  function _mint(address _account, uint256 _amount) internal {
    require(_account != 0);
    totalSupply_ = totalSupply_.add(_amount);
    balances_[_account] = balances_[_account].add(_amount);
    emit Transfer(address(0), _account, _amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param _account The account whose tokens will be burnt.
   * @param _amount The amount that will be burnt.
   */
  function _burn(address _account, uint256 _amount) internal {
    require(_account != 0);
    require(_amount <= balances_[_account]);

    totalSupply_ = totalSupply_.sub(_amount);
    balances_[_account] = balances_[_account].sub(_amount);
    emit Transfer(_account, address(0), _amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal _burn function.
   * @param _account The account whose tokens will be burnt.
   * @param _amount The amount that will be burnt.
   */
  function _burnFrom(address _account, uint256 _amount) internal {
    require(_amount <= allowed_[_account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    allowed_[_account][msg.sender] = allowed_[_account][msg.sender].sub(
      _amount);
    _burn(_account, _amount);
  }
}
