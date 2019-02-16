This is the suggested template for new EIPs.

Note that an EIP number will be assigned by an editor. When opening a pull request to submit your EIP, please use an abbreviated title in the filename, `eip-draft_title_abbrev.md`.

## Preamble

    EIP: <to be assigned>
    Title: Ether Withdrawable API for Inter-contract and Exit Point and Clearing House Operations
    Author: Darryl Morris o0ragman0o@gmail.com
    Type: Standard Track
    Category ERC
    Status: Draft
    Created: 2017-10-25
    Requires (*optional): Nil
    Replaces (*optional): Nil


## Simple Summary
Minimal and extended smart contract API's, is offered to describe the `Withdrawable API`.

On chain movements of ether (in contrast to state channels for example) are typically inhibited by external transaction costs and potential transaction reverts making batched transactions expensive and unreliable. A number of ether accounting patterns are discussed with their associated API functions, `withdrawAll() returns (bool)` and `withdrawAllFor(address[] _kAddrs, address[] _addrs) returns (bool)`, events `Deposit(address indexed _from, uint _value)` and `Withdrawal(address indexed _from, address indexed _to, uint _value)`. Revert prevention and *default function* behaviour are also described. An extended set of optional function interfaces is offered for managing more complex or granular ether accounting.  

## Abstract
A smart contract API is proposed for the initiation of non-reverting withdrawal of *ether* from a contract using *pull payment* and *push-along payment* patterns. Here a *pull payment* is described as a withdrawal of ether from a contract to the caller of that contract. In contrast, a *push-along payment* is introduced as one initiated by a third party address to withdraw ether from a contract to an address accounted by the contract to own an ether value. This is distinct from a *push payment* in which some other action in the contract initiates a transfer of ether from itself to some address.

The API requires avoiding transaction reverts for ether movements to allow for reliable batching of *push-along payments* from contract to contract and external account exit points. To fulfil this requirement, recipient contracts must not exceed stipend gas amounts sent with `<address>.transfer(<value>)`. The withdrawal functions must return `false` upon invalid transfer tests rather than reverting the transaction. By batching non-reverting withdrawal transactions into a single transaction, reliable clearinghouse operations can be run across potentially 100's of ether holding contracts in one transaction.

## Motivation
To date, no smart contract API standard has been specified for the depositing and withdrawal of *ether* to and from an *ether* handling contract. This has left the ecosystem often requiring specific contract knowledge for generally atomic transaction interactions.  Ethereum's inter-contract abilities have not yet been widely exploited by broad frameworks or other systemic inter-operation of individual *ether* holding contracts and accounts. Applications such as on-chain banking, global remittance services, global logistics and extensive DAPP/DAO frameworks will need well defined on chain interfaces and efficient tools for clearing house operations across many 1000's or 100's of 1000's of such contracts and accounts.

Current native, contractual or off chain technology doesn't really offer a reliable bulk value transfer of ether.

ERC20 is one widely accepted interface which defines a mechanism for the storage, transfer and accounting of value holding instruments commonly called *tokens*. ERC20 tokens are typically embodied in a single smart contract making them *contract explicit* and interacted with through the implementation of ERC20 functions to discover and transfer balances within its address/balance register. They are not however suitable for efficient transfers of *ether*.

*Ether*, the intrinsic currency of Ethereum which must be paid as a resource consumption in order to run transactions, differs significantly from ERC20 tokens in its value holding and transfer properties to warrant the development of a specific smart contract API. The primary differences are that *ether* is purely a property of an address and has a liquidity property of being *address agnostic*. Its transfer mechanisms are primitives in the EVM itself rather than an abstract invention in a contract.

Some attempts have been made to address this distinct nature by tokenizing or 'wrapping' *ether* in the ERC20 API that it may be transferred by that mechanism. While it makes sense to have a common interface for all value stores, it does not make sense to have a potential plurality of wrapped ether contracts. 'Wrapped ether' introduces a layer of inefficiency by requiring the ether to first be transferred to the wrapping contract and later unwrapped in order to transfer by native methods. This makes wrapped ether *contract explicit* which destroys its *address agnostic* liquidity property.  Furthermore, the ERC20 standard does not support the *push-along payment pattern* which is desirable for efficient bulk payment processing.

Another alternative is *State Channel Networks* such as *Raiden* which do offer rapid and highly efficient methods of transferring ether and ERC20 tokens but any value holding contract to which those transactions pertain are ignorant of the transactions until the differential value is transferred when a state channel is settled on chain.  This greatly reduces the reliability of a class of contracts which may be dependant upon live calculations from current state, e.g. a derivatives token which dynamically calculate an ether balance given a token holding. They also require that participants run off chain protocols and clients and so are not a native solution. 

The approach offered here is to define a minimal compliant API with two events and a single simple function `withdrawAll()` to withdraw all ether accountable to some internally defined recipient. If that recipient is the caller, then the payment is according to the *pull payment pattern* or if some other address, is according to the *push-along payment pattern*.

Where a contract holds accounting for many addresses, the function `withdrawAllFor()` is also offered by the API which acts in the manner of the *push-along payment pattern*. Further optional functions are also offered for more granular withdrawals.

A stateless singleton contract called *Yank* will be deployed to offer *push-along payment* clearinghouse functionality across potentially 100's of contracts in one transaction. 

## Specification

### Minimal Withdrawable API

The minimal *Withdrawable API* consists of the payable default function, a defined function `withdrawlAll()` and two events `Deposit()` and `Withdrawal()`

#### Deposit
```
event Deposit(address indexed _from, uint _value);
```
A `Deposit` event must be logged upon the contract receiving ANY ether.

`_from` The address from which the ether was sent

`_value` The value of ether which was deposited

#### Withdrawal
```
event Withdrawal(address indexed _from, address indexed _to, uint _value);
```
A `Withdrawal` event must be logged upon ANY ether being transferred from the contract

`_from` An address accounted by the contract from which ether has been withdrawn or the contract address itself if no other address accounting is maintained.

`_to` The address to which the ether was transferred

`_value` The value of ether which was transferred

#### Default Function
```
function () public payable;
```
The default function MUST be payable and MUST NOT exceed the gas stipend of a trivial ether transfer.

#### withdrawAll()
```
function withdrawAll() public returns (bool)
```
To transfer the full account of ether of the sender's address in the *pull payment* pattern or the full account of ether for some other internally defined recipient address in the *push-along payment* pattern.

The function SHOULD validate a transfer to avoid a potential revert and MUST return a boolean success value.

### Extended Withdrawable API

The extended Withdrawable API consists of *optional* functions for the purpose of granular ether accounting and withdrawal.

#### etherBalanceOf
```
function etherBalanceOf(address _addr) public view returns (uint);
```
Returns the balance of ether accountable to an address. This function is named similar to the ERC20 function `balanceOf()` but is kept distinct for contracts which may account both in ether and ERC20 tokens.

`_addr` An address registered in the contract to hold a value of ether.

Returns a value of ether which is withdrawable to the address.

#### WithdrawAllFor
```
function withdrawAllFor(address[] _addrs) public returns (bool);
```
To transfer the full account of ether accounted to the each of the array of addresses provided according to the *push-along payment* pattern.

`_addrs` An array of addresses registered in the contract to hold values of ether.

The function SHOULD validate each transfer to avoid a potential revert and MUST return a boolean success value.

#### withdraw
```
function withdraw(uint _value) public returns (bool);
```
To transfer the a specific value of ether account to the sender or other internally specified address.

`_value` A specific value to be transferred

The function SHOULD validate the transfer to avoid a potential revert and MUST return a boolean success value.

#### withdrawFor
```
function withdrawFor(address[] _addrs, uint[] _values) public returns (bool);
```
To transfer the spcific amounts of ether accounted to the each of the array of addresses provided according to the *push-along payment* pattern.

`_addrs` An array of addresses registered in the contract to hold values of ether.

`_values` An array of values to withdraw to the address of their respective indecies. 

The function SHOULD validate each transfer to avoid a potential revert and MUST return a boolean success value.

#### withdrawTo
```
function withdrawTo(address _to, uint _value) public returns (bool);
```
To withdraw a value of ether accounted to the sender according to the *pull payment pattern* and have it transferred to a third-party address.

`_to` An address to which the ether is transferred

`_value` The amount of ether to transfer

The function SHOULD validate the transfer to avoid a potential revert and MUST return a boolean success value.

#### withdrawlAllFrom
```
function withdrawAllFrom(address _kAddr) public returns (bool);
```
For a contract to call the *pull payment patterned* function `withdrawAll()` upon another contract in which it may have a withdrawable balance of ether.

`_kAddr` A smart contract address which implements the minimal *Withdrawable API*

The function MUST return a boolean success value.

#### withdrawFrom
```
function withdrawFrom(address _kAddr, uint _value) public returns (bool);
```
For a contract to call *pull payment patterned* function `withdraw(_value)` upon another contract in which it may have a withdrawable balance of ether.

`_kAddr` A smart contract address which implements `withdraw(_value)` of the extended *Withdrawable API*

`_value` The amount of ether to transfer

The function MUST return a boolean success value.

## Rationale
This API has been developed to support ether accounting and transacting within a framework of related smart contracts.  It became apparent that the contracts themselves would be holding ether balances in other contracts and require a common API in order to predictably and reliably withdraw that ether along emergent chains and networks of contractual relationships to exit point addresses.  Initiating *pull payments* alone at end point contracts would necessitate that contracts be intelligent enough to discover upstream contracts and balances they hold.  Such intelligence would be complex and expensive to implement and run so the alternative `push-along payment pattern` has been described in which the payment channels can be discovered off chain and payments processed by providing a clearing house contract arrays of addresses from which payments can be pushed along, aggregated and exited.

Deposit permissioning and blocking was also to be featured in the API however the `default function` cannot return a value which leaves the only blocking option being a *revert* of the transaction. This would break the reliability requirment of the API and so has been dropped as a feature.         

## Backwards Compatibility
This EIP has no predecessors. 

## Test Cases
This EIP does not require a change of consensus protocol.

## Implementation
The implementations must be completed before any EIP is given status "Final", but it need not be completed before the EIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
