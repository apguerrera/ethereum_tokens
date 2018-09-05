var whitelistOutput={
   "contracts" : {
      "DeveryPresaleWhitelist.sol:Admined" : {
         "abi" : "[{\"constant\":false,\"inputs\":[{\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"removeAdmin\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"address\"}],\"name\":\"admins\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"addAdmin\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[],\"name\":\"acceptOwnership\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"newOwner\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_newOwner\",\"type\":\"address\"}],\"name\":\"transferOwnership\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"AdminAdded\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"AdminRemoved\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"}],\"name\":\"OwnershipTransferred\",\"type\":\"event\"}]",
         "bin" : "606060405260008054600160a060020a033316600160a060020a03199091161790556103a2806100306000396000f3006060604052600436106100825763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631785f53c8114610087578063429b62e5146100a857806370480275146100db57806379ba5097146100fa5780638da5cb5b1461010d578063d4ee1d901461013c578063f2fde38b1461014f575b600080fd5b341561009257600080fd5b6100a6600160a060020a036004351661016e565b005b34156100b357600080fd5b6100c7600160a060020a03600435166101eb565b604051901515815260200160405180910390f35b34156100e657600080fd5b6100a6600160a060020a0360043516610200565b341561010557600080fd5b6100a6610280565b341561011857600080fd5b61012061030e565b604051600160a060020a03909116815260200160405180910390f35b341561014757600080fd5b61012061031d565b341561015a57600080fd5b6100a6600160a060020a036004351661032c565b60005433600160a060020a0390811691161461018957600080fd5b600160a060020a03811660009081526002602052604090819020805460ff191690557fa3b62bc36326052d97ea62d63c3d60308ed4c3ea8ac079dd8499f1e9c4f80c0f90829051600160a060020a03909116815260200160405180910390a150565b60026020526000908152604090205460ff1681565b60005433600160a060020a0390811691161461021b57600080fd5b600160a060020a03811660009081526002602052604090819020805460ff191660011790557f44d6d25963f097ad14f29f06854a01f575648a1ef82f30e562ccd3889717e33990829051600160a060020a03909116815260200160405180910390a150565b60015433600160a060020a0390811691161461029b57600080fd5b600154600054600160a060020a0391821691167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a3600180546000805473ffffffffffffffffffffffffffffffffffffffff19908116600160a060020a03841617909155169055565b600054600160a060020a031681565b600154600160a060020a031681565b60005433600160a060020a0390811691161461034757600080fd5b6001805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a03929092169190911790555600a165627a7a72305820f07dda61c3e9135866bb55a416d267a627033b0067f8151190d48805689896c00029"
      },
      "DeveryPresaleWhitelist.sol:DeveryPresaleWhitelist" : {
         "abi" : "[{\"constant\":false,\"inputs\":[{\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"removeAdmin\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[],\"name\":\"seal\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"address\"}],\"name\":\"admins\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"addAdmin\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[],\"name\":\"acceptOwnership\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"address\"}],\"name\":\"whitelist\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"newOwner\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"sealed\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"addresses\",\"type\":\"address[]\"},{\"name\":\"max\",\"type\":\"uint256[]\"}],\"name\":\"multiAdd\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_newOwner\",\"type\":\"address\"}],\"name\":\"transferOwnership\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"addr\",\"type\":\"address\"},{\"name\":\"max\",\"type\":\"uint256\"}],\"name\":\"add\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"addr\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"max\",\"type\":\"uint256\"}],\"name\":\"Whitelisted\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"AdminAdded\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"AdminRemoved\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"}],\"name\":\"OwnershipTransferred\",\"type\":\"event\"}]",
         "bin" : "6060604052341561000f57600080fd5b60008054600160a060020a033316600160a060020a03199091161790556107558061003b6000396000f3006060604052600436106100b95763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631785f53c81146100c65780633fb27b85146100e5578063429b62e5146100f8578063704802751461012b57806379ba50971461014a5780638da5cb5b1461015d5780639b19251a1461018c578063d4ee1d90146101bd578063e4b203ef146101d0578063e6979b90146101e3578063f2fde38b14610272578063f5d82b6b14610291575b34156100c457600080fd5b005b34156100d157600080fd5b6100c4600160a060020a03600435166102b3565b34156100f057600080fd5b6100c4610330565b341561010357600080fd5b610117600160a060020a036004351661036a565b604051901515815260200160405180910390f35b341561013657600080fd5b6100c4600160a060020a036004351661037f565b341561015557600080fd5b6100c46103ff565b341561016857600080fd5b61017061048d565b604051600160a060020a03909116815260200160405180910390f35b341561019757600080fd5b6101ab600160a060020a036004351661049c565b60405190815260200160405180910390f35b34156101c857600080fd5b6101706104ae565b34156101db57600080fd5b6101176104bd565b34156101ee57600080fd5b6100c46004602481358181019083013580602081810201604051908101604052809392919081815260200183836020028082843782019150505050505091908035906020019082018035906020019080806020026020016040519081016040528093929190818152602001838360200280828437509496506104c695505050505050565b341561027d57600080fd5b6100c4600160a060020a0360043516610626565b341561029c57600080fd5b6100c4600160a060020a0360043516602435610670565b60005433600160a060020a039081169116146102ce57600080fd5b600160a060020a03811660009081526002602052604090819020805460ff191690557fa3b62bc36326052d97ea62d63c3d60308ed4c3ea8ac079dd8499f1e9c4f80c0f90829051600160a060020a03909116815260200160405180910390a150565b60005433600160a060020a0390811691161461034b57600080fd5b60035460ff161561035b57600080fd5b6003805460ff19166001179055565b60026020526000908152604090205460ff1681565b60005433600160a060020a0390811691161461039a57600080fd5b600160a060020a03811660009081526002602052604090819020805460ff191660011790557f44d6d25963f097ad14f29f06854a01f575648a1ef82f30e562ccd3889717e33990829051600160a060020a03909116815260200160405180910390a150565b60015433600160a060020a0390811691161461041a57600080fd5b600154600054600160a060020a0391821691167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a3600180546000805473ffffffffffffffffffffffffffffffffffffffff19908116600160a060020a03841617909155169055565b600054600160a060020a031681565b60046020526000908152604090205481565b600154600160a060020a031681565b60035460ff1681565b600160a060020a03331660009081526002602052604081205460ff16806104fb575060005433600160a060020a039081169116145b151561050657600080fd5b60035460ff161561051657600080fd5b8251151561052357600080fd5b815183511461053157600080fd5b5060005b82518110156106215782818151811061054a57fe5b90602001906020020151600160a060020a0316151561056857600080fd5b81818151811061057457fe5b906020019060200201516004600085848151811061058e57fe5b90602001906020020151600160a060020a031681526020810191909152604001600020558281815181106105be57fe5b90602001906020020151600160a060020a03167f6ea640312e182de387819fbeb13be00db3171a445412852248559054871c41998383815181106105fe57fe5b9060200190602002015160405190815260200160405180910390a2600101610535565b505050565b60005433600160a060020a0390811691161461064157600080fd5b6001805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0392909216919091179055565b600160a060020a03331660009081526002602052604090205460ff16806106a5575060005433600160a060020a039081169116145b15156106b057600080fd5b60035460ff16156106c057600080fd5b600160a060020a03821615156106d557600080fd5b600160a060020a038216600081815260046020526040908190208390557f6ea640312e182de387819fbeb13be00db3171a445412852248559054871c41999083905190815260200160405180910390a250505600a165627a7a7230582027fe556fea4f54a2a54ac7121cfb5c7ad04537dfd5644b5ba1a7dd004c998a660029"
      },
      "DeveryPresaleWhitelist.sol:Owned" : {
         "abi" : "[{\"constant\":false,\"inputs\":[],\"name\":\"acceptOwnership\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"newOwner\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_newOwner\",\"type\":\"address\"}],\"name\":\"transferOwnership\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"}],\"name\":\"OwnershipTransferred\",\"type\":\"event\"}]",
         "bin" : "6060604052341561000f57600080fd5b60008054600160a060020a033316600160a060020a03199091161790556101fe8061003b6000396000f3006060604052600436106100615763ffffffff7c010000000000000000000000000000000000000000000000000000000060003504166379ba509781146100665780638da5cb5b1461007b578063d4ee1d90146100aa578063f2fde38b146100bd575b600080fd5b341561007157600080fd5b6100796100dc565b005b341561008657600080fd5b61008e61016a565b604051600160a060020a03909116815260200160405180910390f35b34156100b557600080fd5b61008e610179565b34156100c857600080fd5b610079600160a060020a0360043516610188565b60015433600160a060020a039081169116146100f757600080fd5b600154600054600160a060020a0391821691167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a3600180546000805473ffffffffffffffffffffffffffffffffffffffff19908116600160a060020a03841617909155169055565b600054600160a060020a031681565b600154600160a060020a031681565b60005433600160a060020a039081169116146101a357600080fd5b6001805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a03929092169190911790555600a165627a7a7230582080fb45739cd9ff76b2d7870c44aa1fd4c4729db79d4a614657ead035f33bec780029"
      }
   },
   "version" : "0.4.18+commit.9cf6e910.Darwin.appleclang"
};
