/*
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
pragma solidity ^0.4.24;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

import "../ERC777/ERC777Issuable.sol";


/**
 * @title ERC777ERC20
 * @dev ERC777 with ERC20 retrocompatibility
 */
contract ERC777ERC20 is IERC20, ERC777Issuable {

  bool internal _erc20compatible;

  // Mapping from (tokenHolder, spender) to allowed value.
  mapping (address => mapping (address => uint256)) internal _allowed;

  /**
   * @dev Modifier to verify if ERC20 retrocompatible are locked/unlocked.
   */
  modifier erc20Compatible() {
    require(_erc20compatible, "Action Blocked - Token restriction");
    _;
  }

  /**
   * [ERC777ERC20 CONSTRUCTOR]
   * @dev Initialize ERC777ERC20 and CertificateController parameters + register
   * the contract implementation in ERC820Registry.
   * @param name Name of the token.
   * @param symbol Symbol of the token.
   * @param granularity Granularity of the token.
   * @param controllers Array of initial controllers.
   * @param certificateSigner Address of the off-chain service which signs the
   * conditional ownership certificates required for token transfers, issuance,
   * redemption (Cf. CertificateController.sol).
   */
  constructor(
    string name,
    string symbol,
    uint256 granularity,
    address[] controllers,
    address certificateSigner
  )
    public
    ERC777(name, symbol, granularity, controllers, certificateSigner)
  {}

  /**
   * [OVERRIDES ERC777 METHOD]
   * @dev Perform the transfer of tokens.
   * @param operator The address performing the transfer.
   * @param from Token holder.
   * @param to Token recipient.
   * @param value Number of tokens to transfer.
   * @param data Information attached to the transfer.
   * @param operatorData Information attached to the transfer by the operator (if any).
   * @param preventLocking 'true' if you want this function to throw when tokens are sent to a contract not
   * implementing 'erc777tokenHolder'.
   * ERC777 native transfer functions MUST set this parameter to 'true', and backwards compatible ERC20 transfer
   * functions SHOULD set this parameter to 'false'.
   */
  function _transferWithData(
    address operator,
    address from,
    address to,
    uint256 value,
    bytes data,
    bytes operatorData,
    bool preventLocking
  )
   internal
  {
    ERC777._transferWithData(operator, from, to, value, data, operatorData, preventLocking);

    if(_erc20compatible) {
      emit Transfer(from, to, value);
    }
  }

  /**
   * [OVERRIDES ERC777 METHOD]
   * @dev Perform the token redemption.
   * @param operator The address performing the redemption.
   * @param from Token holder whose tokens will be redeemed.
   * @param value Number of tokens to redeem.
   * @param data Information attached to the redemption.
   * @param operatorData Information attached to the redemption by the operator (if any).
   */
  function _redeem(address operator, address from, uint256 value, bytes data, bytes operatorData) internal {
    ERC777._redeem(operator, from, value, data, operatorData);

    if(_erc20compatible) {
      emit Transfer(from, address(0), value);  //  ERC20 backwards compatibility
    }
  }

  /**
   * [OVERRIDES ERC777 METHOD]
   * @dev Perform the issuance of tokens.
   * @param operator Address which triggered the issuance.
   * @param to Token recipient.
   * @param value Number of tokens issued.
   * @param data Information attached to the issuance.
   * @param operatorData Information attached to the issued by the operator (if any).
   */
  function _issue(address operator, address to, uint256 value, bytes data, bytes operatorData) internal {
    ERC777._issue(operator, to, value, data, operatorData);

    if(_erc20compatible) {
      emit Transfer(address(0), to, value); // ERC20 backwards compatibility
    }
  }

  /**
   * [OVERRIDES ERC777 METHOD]
   * @dev Get the number of decimals of the token.
   * @return The number of decimals of the token. For Backwards compatibility, decimals are forced to 18 in ERC777.
   */
  function decimals() external view erc20Compatible returns(uint8) {
    return uint8(18);
  }

  /**
   * [NOT MANDATORY FOR ERC777 STANDARD]
   * @dev Check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address owner, address spender) external view erc20Compatible returns (uint256) {
    return _allowed[owner][spender];
  }

  /**
   * [NOT MANDATORY FOR ERC777 STANDARD]
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of 'msg.sender'.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   * @return A boolean that indicates if the operation was successful.
   */
  function approve(address spender, uint256 value) external erc20Compatible returns (bool) {
    require(spender != address(0), "A6: Transfer Blocked - Receiver not eligible");
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * [NOT MANDATORY FOR ERC777 STANDARD]
   * @dev Transfer token for a specified address.
   * @param to The address to transfer to.
   * @param value The amount to be transferred.
   * @return A boolean that indicates if the operation was successful.
   */
  function transfer(address to, uint256 value) external erc20Compatible returns (bool) {
    _transferWithData(msg.sender, msg.sender, to, value, "", "", false);
    return true;
  }

  /**
   * [NOT MANDATORY FOR ERC777 STANDARD]
   * @dev Transfer tokens from one address to another.
   * @param from The address which you want to transfer tokens from.
   * @param to The address which you want to transfer to.
   * @param value The amount of tokens to be transferred.
   * @return A boolean that indicates if the operation was successful.
   */
  function transferFrom(address from, address to, uint256 value) external erc20Compatible returns (bool) {
    address _from = (from == address(0)) ? msg.sender : from;
    require( _isOperatorFor(msg.sender, _from)
      || (value <= _allowed[_from][msg.sender]), "A7: Transfer Blocked - Identity restriction");

    if(_allowed[_from][msg.sender] >= value) {
      _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(value);
    } else {
      _allowed[_from][msg.sender] = 0;
    }

    _transferWithData(msg.sender, _from, to, value, "", "", false);
    return true;
  }

  /***************** ERC777ERC20 OPTIONAL FUNCTIONS ***************************/

  /**
   * [NOT MANDATORY FOR ERC777ERC20 STANDARD]
   * @dev Register/Unregister the ERC20Token interface with its own address via ERC820.
   * @param erc20compatible 'true' to register the ERC20Token interface, 'false' to unregister.
   */
  function setERC20compatibility(bool erc20compatible) external onlyOwner {
    _setERC20compatibility(erc20compatible);
  }

  /**
   * [NOT MANDATORY FOR ERC777ERC20 STANDARD]
   * @dev Register/unregister the ERC20Token interface.
   * @param erc20compatible 'true' to register the ERC20Token interface, 'false' to unregister.
   */
  function _setERC20compatibility(bool erc20compatible) internal {
    _erc20compatible = erc20compatible;
    if(_erc20compatible) {
      setInterfaceImplementation("ERC20Token", this);
    } else {
      setInterfaceImplementation("ERC20Token", address(0));
    }
  }

}
