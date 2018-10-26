pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// Deepy Security Token
//
// Authors:
// * Adrian Guerrera / Deepyr Pty Ltd
// * BokkyPooBah / Bok Consulting Pty Ltd
//
// Oct 18 2018
//
// Minime token
// BTTS
// URL: ClubEth.App
// GitHub: https://github.com/bokkypoobah/ClubEth
// ----------------------------------------------------------------------------

//-----------------OUTLINE---------------------
/*
Whitelist
Total tokens
        Collect total for all the generated tokens
checkpointing
        Mini me token -> BTTS
dividends
     Minime
lockups (eg 90 days)
freeze / mint / burn
        BTTS / Mintable / stoppable
different classes
    Different tokens
mainToken
  subtokens / trenches
    conversion contract

        BTTS token with no factory and a conversion contract
            Transfer to owner, burn, mint new, transfer back new tokens
voting
      Club Eth
*/
//---------------------------------------------

import "Owned.sol";
import "Operated.sol";
import "SafeMath.sol";
import "BTTSTokenInterface110.sol";
import "WhiteListInterface.sol";

contract DeepyrSecurityToken is Owned, ApproveAndCallFallBack {
  using SafeMath for uint;
  uint private constant TENPOW18 = 10 ** 18;
  BTTSTokenInterface public baseToken;
  WhiteListInterface public whiteList;

  struct Checkpoint {
    uint128 fromBlock;
    uint128 value;
  }
  /*
  struct SubToken {
      BTTSTokenInterface public address;
  }
  */
  Checkpoint[] totalSupplyHistory;
  // SubToken[] subTokens;

  constructor(address _baseToken, address _whiteList) public {
    require(_baseToken != address(0) && _whiteList != address(0));
    initOwned(msg.sender);
    baseToken = BTTSTokenInterface(_baseToken);
    whiteList = WhiteListInterface(_whiteList);
    // add to totalSupplyHistory { block.number, baseToken.totalSupply(); }
  }

  function symbol() public view returns (string _symbol) {
      _symbol = baseToken.symbol();
  }
  function name() public view returns (string _name) {
      _name = baseToken.name();
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
    if (_block >= checkpoints[checkpoints.lenght-1].fromBlock) {
        checkpoints[checkpoints.lenght-1].value
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

  function generateTokens (address _owner, uint amount) public onlyOwner returns (bool) {}
  function destroyTokens (address _owner, uint amount) public onlyOwner returns (bool) {}

  // function createSubToken() public onlyOwner returns (address) {

  // footer functions
  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
      return ERC20Interface(tokenAddress).transfer(owner, tokens);
  }

  function () public payable {
      revert();
  }
}

contract DeepyrSecurityFactory is Owner {

  DeepyrSecurityToken public mainToken;
  DeepyrSecurityToken[] public deployedTokens;
  mapping(address => bool) _verify;

  event SecurityTokenListing(address indexed tokenAddress);

  constructor () {
      // not finished, waiting on below function
      (securityToken, token, whitelist) = deploySecurityToken("DEEPYR", "Deepyr Security Token", 18);
      mainToken = securityToken;
  }

  // not finished
  function deploySecurityToken (
        string tokenSymbol
        , string tokenName
        , uint8 tokenDecimals
        // need to fix return
    ) public returns (securityToken, token, whitelist) {

      // need to redo with BTTS constructor
      token = new BTTSToken(tokenSymbol, tokenName, tokenDecimals);
      // need to fix this
      whitelist = new WhiteList();
      _verify[address(token)] = true;
      deployedTokens.push(token);
      securityToken = new DeepyrSecurityToken(token, whitelist);
      emit SecurityTokenListing(address(securityToken, token, whitelist));
  }

  function numberOfDeployedTokens() public view returns (uint) {
      return deployedTokens.length;
  }
  function verify(address addr) public view returns (bool valid) {
      valid = _verify[addr];
  }
  function totalSupply() public view returns (uint) {
      return mainToken.totalSupply();
  }

  function totalSupplyOfAllTokens() public view returns (uint) {
      uint _sum = 0;
      uint _count = 0;
      while (_count < deployedTokens.length) {
        _sum += deployedTokens[_count].totalSupply();
        _count ++;
      }
      return _sum;
  }

  // footer functions
  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
      return ERC20Interface(tokenAddress).transfer(owner, tokens);
  }

  function () public payable {
      revert();
  }
}
