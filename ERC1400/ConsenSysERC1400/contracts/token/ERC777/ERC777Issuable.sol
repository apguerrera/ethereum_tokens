pragma solidity ^0.4.24;

import "./ERC777.sol";

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

/**
 * @title ERC777Issuable
 * @dev ERC777 issuance logic
 */
contract ERC777Issuable is ERC777, MinterRole {

  /**
   * [NOT MANDATORY FOR ERC777 STANDARD]
   * @dev Issue the amout of tokens for the recipient 'to'.
   * @param to Token recipient.
   * @param value Number of tokens issued.
   * @param data Information attached to the issuance, by the token holder. [CONTAINS THE CONDITIONAL OWNERSHIP CERTIFICATE]
   * @return A boolean that indicates if the operation was successful.
   */
  function issue(address to, uint256 value, bytes data)
    external
    isValidCertificate(data)
    onlyMinter
    returns (bool)
  {
    _issue(msg.sender, to, value, data, "");

    return true;
  }

}
