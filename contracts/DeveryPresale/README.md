# Devery Presale Contract

## Summary

The Devery presale contract is a combined presale and token contract. Participants contribute ethers (ETH) to the presale / token
contract address and tokens are generated for the contributing account at the rate of one token per ETH contributed.

The `PREVE` `Presale EVE Tokens` are non-transferable tokens that will later be used in the crowdsale contract to determine the
number of crowdsale tokens to mint for each presale contributor.

### Mainnet Addresses

`TBA`

<br />

### Presale Contract

* Participants can contribute to the presale contract after the specified start date
* There is no specified end date for this presale contract. The presale automatically closes when/if the contributed ETH reaches
  the cap. The presale can also be manually closed by the token contract owner executing the `closeSale()` function
* Participants intending to contribute to the presale contract will need to have their ETH account whitelisted by Devery **OR** the
  Parity PICOPS system
* The DeveryPresaleWhitelist contract whitelist entries are used to verify the whitelisted addresses where the `max` amount is > 0 .
  The `max` amount value is not checked against the contributed ETH value
* There is a minimum contribution amount. The token contract owner is able to change this minimum amount at anytime during the presale period
* The presale contract has a contribution cap that is specified in USD. The token contract owner is able to change this cap amount at
  anytime during the presale period
* The ETH/USD exchange rate is specified in the presale contract, and can be updated by texecuting the `setUsdPerKEther(...)` function.
  This function can be executed by the token contract owner at anytime during the presale period
* The presale contract *DeveryPresaleWhitelist* contract address can be updated by executing the `setWhitelist(...)` function. This
  function can be executed by the token contract owner at anytime during the presale period
* The presale contract Parity PICOPS Certifier contract address can be updated by executing the `setPICOPSCertifier(...)` function. This
  function can be executed by the token contract owner at anytime during the presale period

<br />

### Token Contract

* The PREVE token contract implements the recently finalised [ERC-20 Token Standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
* The PREVE tokens have 18 decimal places like the ETH token
* The PREVE tokens are **NOT** transferable by default. The token owner can enable transfers by executing the `enableTransfers()` function,
  but this is not the intended behaviour for this token contract

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
  * [Mainnet Addresses](#mainnet-addresses)
  * [Presale Contract](#presale-contract)
  * [Token Contract](#token-contract)
* [Requirements](#requirements)
* [Testing](#testing)
  * [Test 1 Happy Path](#test-1-happy-path)
* [Code Review](#code-review)

<br />

<hr />

## Requirements

* Presale opens Dec 10 2017 12:00:00 AEDT
* Presale closes if cap reached, or when owner closes the presale
* Check deployed whitelist for `max > 0` **OR** Parity PICOPS `certified(addr) == true` before accepting funds
* Presale capped at USD 2 million
* ETH/USD rate set prior to presale open date
* Minimum contribution 20 ETH
* Sample PICOPS contract https://etherscan.io/address/0x1e2f058c43ac8965938f6e9ca286685a3e63f24e#code
* Devery Presale Whitelist https://etherscan.io/address/0x38E330C4330e743a4D82D93cdC826bAe78C6E7A6#code

<br />

<hr />

## Testing

### Test 1 Happy Path

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [x] Deploy the Devery whitelist contract
* [x] Whitelist a few contributing addresses
* [x] Deploy Test PICOPSCertifier contract - address 0xa44a hardcoded to return true
* [x] Deploy the presale/token contract
* [x] Set presale/token contract parameters
  * [x] Set ETH min contribution amount
  * [x] Set USD cap
  * [x] Set USD per 1,000 ETH
  * [x] Assign the whitelist
  * [x] Assign the PICOPSCertifier
* [x] Wait until start date
* [x] Contribute from whitelisted address below cap
* [x] Contribute from non-whitelisted address below cap, expecting failure
* [x] Contribute above cap, excess refunded
* [x] Increase cap
* [x] Contribute below cap 
* [x] Manually close sale

Details of the testing environment can be found in [test](test).

<br />

<hr />

## Code Review

Note that this is a code review by the author of the contracts:

* [x] [code-review/DeveryPresale.md](code-review/DeveryPresale.md)
  * [x] contract DeveryPresaleWhitelist
  * [x] contract PICOPSCertifier
  * [x] contract SafeMath
  * [x] contract ERC20Interface
  * [x] contract Owned
  * [x] contract ERC20Token is ERC20Interface, Owned, SafeMath
  * [x] contract DeveryPresale is ERC20Token
* [x] [code-review/DeveryPresaleWhitelist.md](code-review/DeveryPresaleWhitelist.md)
  * [x] contract Owned
  * [x] contract Admined is Owned
  * [x] contract DeveryPresaleWhitelist is Admined
* [x] [code-review/TestPICOPSCertifier.md](code-review/TestPICOPSCertifier.md)
  * [x] contract TestPICOPSCertifier

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Devery - Dec 14 2017. The MIT Licence.