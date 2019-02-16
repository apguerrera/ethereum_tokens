# Withdrawable
v0.4.3

A contract API and example implementation to provision point to point pull 
payments from contract to contract or contract to external account using
a *withdraw* paradigm rather than *transfer*.

Ether differs significantly from other value mechanisms such as ERC20 tokens
in that it is intrinsically transferrable between accounts rather than addresses
being registered against tokens existing only in a contract.
While ERC20 offers `transfer()` and `transferFrom()` which have inspired
'wrapped ether' for token like transfers of ether within a contract, the nature
of ether differs enough from tokens for *ether* to warrent a dedicated API
standard for moving money between contracts and addresses to which destinations
and values are internally defined but caller need not be.

Payment channels, for example, might have a single internally defined recipient
so there is no need to permission the caller of `withdrawAll()` so as to
allow any address to call it and move the money to that recipient.  This makes
contract to contract transfers and clearing house operations simpler.

The minimal API defines `withdrawAll()` along with events `Deposit()` and
`Withdrawal()` with all other state variables and functions in the extended API
being optional. 

# Yank
To facilitate economical clearing house transactions, a stateless singleton
contract called `Yank` can be supplied arrays of withdrawable contract addresses
and respective recipient addresses with which to pull money through a chain or
group of contracts to exit addresses.

## WithdrawableMinAbstract
### ABI
```
[{"constant":false,"inputs":[],"name":"withdrawAll","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Deposit","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Withdrawal","type":"event"}]
```

### withdrawAll
```
function withdrawAll() public returns (bool);
```
Withdraws entire balance to the sender or other internally specified address.

Returns success boolean

### Events
```
event Deposit(address indexed _from, uint _value)
```
Logged upon receiving a deposit.

`_from` The sender address

`_value` The value of ether recieved

    
```
event Withdrawal(address indexed _from, address indexed _to, uint _value)
```
Logged upon a withdrawal.

`_from` The address account by the contract to have owned the ether

`_to` The addres to which funds were sent

`_value` The value of ether sent



## WithdrawableAbstract

### ABI
```
[{"constant":true,"inputs":[{"name":"_addr","type":"address"}],"name":"etherBalanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"withdrawTo","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_value","type":"uint256"}],"name":"withdraw","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"withdrawAll","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_value","type":"uint256"}],"name":"withdrawFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_addrs","type":"address[]"},{"name":"_values","type":"uint256[]"}],"name":"withdrawFor","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_addrs","type":"address[]"}],"name":"withdrawAllFor","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"}],"name":"withdrawAllFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Deposit","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Withdrawal","type":"event"}]
```

### etherBalanceOf
```
function etherBalanceOf(address _addr) public view returns (uint)
```
Recommended

Returns the balance of ether held in the contract for `_addr`

`_addr` An ethereum address

### withdrawAll
```
function withdrawAll() public returns (bool);
```
Required

Withdraws entire balance of sender to the sender or other internally specified
address.

Returns success boolean

### withdraw
```
function withdraw(uint _value) public returns (bool)
```
Optional

Withdraws a value of ether from the contract. Returns success boolean.

`_value` the value to withdraw

### withdrawTo
```
function withdrawTo(address _to, uint _value) public returns (bool)
```
Optional

Withdraws a value of ether from the contract sending it to a thirdparty address.

`_to` a recipient address

`_value` the value to withdraw

Returns success boolean

### withdrawAllFor
```
function withdrawAllFor(address[] _addrs) public returns (bool)
```
Sends entire balance of the supplied address to the supplied address

`_addr` a holder address in the contract

Returns success boolean
    
### withdrawFor
```
function withdrawFor(address[] _addrs, uint[] _values) public returns (bool)
```
Optional

Sends a value of ether held for an address to that address.

`_addr` a holder address in the contract

`_value` the value to withdraw

Return success boolean

### withdrawAllFrom
```
function withdrawAllFrom(address _kAddr) public returns (bool)
```
Optional

Withdraws all awarded ether from an external `Withdrawable` contract in
which the current contract address may hold value. This function calls the
`withdrawAll()` function of the thirdparty contract.

`_kAddr` The address of a third party `Withdrawable` contract.'

`_value` The value to withdraw into the current contract.

Returns success boolean

### withdrawFrom
```
function withdrawFrom(address _kAddr, uint _value) public returns (bool)
```
Optional

Withdraws a value of ether from an external `Withdrawable` contract in
which the current contract address may hold value. This function calls the
`withdraw(value)` function of the thirdparty contract.

`_kAddr` The address of a third party `Withdrawable` contract.'

`_value` The value to withdraw into the current contract.

Returns success boolean

### Events
```
event Deposit(address indexed _from, uint _value)
```
Logged upon receiving a deposit.

`_from` The sender address

`_value` The value of ether recieved


```
event Withdrawal(address indexed _from, address indexed _to, uint _value)
```
Logged upon a withdrawal.

`_from` The address account by the contract to have owned the ether

`_to` The addres to which funds were sent

`_value` The value of ether sent

## Yank
### ABI
```
[{"constant":false,"inputs":[{"name":"_kAddrs","type":"address[]"},{"name":"_addrs","type":"address[]"}],"name":"yank","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"regName","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"VERSION","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_kAddr","type":"address"}],"name":"WithdrawnAll","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_kAddr","type":"address"},{"indexed":true,"name":"_for","type":"address"}],"name":"WithdrawnAllFor","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_kAddr","type":"address"},{"indexed":true,"name":"_for","type":"address"}],"name":"Failed","type":"event"}]
```

### VERSION
```
function VERSION() public constant returns (bytes32)
```
Returns the UTF8 encoded version as a bytes32

### regName
```
function regName() public constant returns (bytes32)
```
Returns 'yank' as a bytes32 type for registration with the SandalStraps framework

### yank
```
function yank(address[] _kAddrs, address[] _addrs) public returns (bool);
```
Performs clearing house pull payments across an array of withdrawable contracts by
by calling `withdrawAll()` and `withdrawAllFor()`. Chained contracts should be ordered
furtherest to closest. Any throws in the chain will revert the transaction.
`_kAddrs` and `_addrs` must be of equal length with `_addrs` values being `0x0` where
no recipient address is required. Ether that may have accumulated in the Yank contract
itself is sent to msg.sender at the end of the call.

`_kAddrs[]` An array of withdrawable contracts

`_addrs[]` An array of recipient addresses

### Events
```
event WithdrawnAll(address indexed _kAddr);
```
Logged when a call to WithdrawlAll is made

```
event WithdrawnAllFor(address indexed _kAddr, address indexed _for);
```
Logged when a call to WithdrawAllFor is made

```
event Failed(address indexed _kAddr, address indexed _for);
```
Logged when a withdraw fails and does not revert the transaction.

