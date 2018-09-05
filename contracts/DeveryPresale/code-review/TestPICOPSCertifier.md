# TestPICOPSCertifier

Source file [../contracts/TestPICOPSCertifier.sol](../contracts/TestPICOPSCertifier.sol).

The source of the PICOPS contract is [0x1e2f058c43ac8965938f6e9ca286685a3e63f24e](https://etherscan.io/address/0x1e2f058c43ac8965938f6e9ca286685a3e63f24e#code)
and the name of the contract is *Certifier*.

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// BK Ok
contract TestPICOPSCertifier {
    // BK Ok - `view` is `constant` in the PICOPS contract
    function certified(address addr) public view returns (bool) {
        // BK Ok
        return (addr == 0xa44a08d3F6933c69212114bb66E2Df1813651844);
    }
}
```
