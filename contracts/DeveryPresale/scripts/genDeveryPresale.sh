#!/bin/sh

geth attach << EOF | grep "JSONSUMMARY:" | sed "s/JSONSUMMARY: //" > tmp.json
loadScript("deveryPresale.js");
// loadScript("whiteList.js");

function generateSummaryJSON() {
  console.log("JSONSUMMARY: {");
  var whiteList = null
  // if (whiteListAddress != null && whiteListAbi != null) {
  //   whiteList = eth.contract(whiteListAbi).at(whiteListAddress);
  // }
  if (crowdsaleContractAddress != null && crowdsaleContractAbi != null) {
    var contract = eth.contract(crowdsaleContractAbi).at(crowdsaleContractAddress);
    var blockNumber = eth.blockNumber;
    var timestamp = eth.getBlock(blockNumber).timestamp;
    console.log("JSONSUMMARY:   \"blockNumber\": " + blockNumber + ",");
    console.log("JSONSUMMARY:   \"blockTimestamp\": " + timestamp + ",");
    console.log("JSONSUMMARY:   \"blockTimestampString\": \"" + new Date(timestamp * 1000).toString() + "\",");
    console.log("JSONSUMMARY:   \"blockTimestampUTCString\": \"" + new Date(timestamp * 1000).toUTCString() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleContractAddress\": \"" + crowdsaleContractAddress + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleContractOwnerAddress\": \"" + contract.owner() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleContractNewOwnerAddress\": \"" + contract.newOwner() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleWalletAddress\": \"" + contract.wallet() + "\",");
    console.log("JSONSUMMARY:   \"tokenSymbol\": \"" + contract.symbol() + "\",");
    console.log("JSONSUMMARY:   \"tokenName\": \"" + contract.name() + "\",");
    console.log("JSONSUMMARY:   \"tokenDecimals\": \"" + contract.decimals() + "\",");
    console.log("JSONSUMMARY:   \"tokenTotalSupply\": \"" + contract.totalSupply().shift(-18) + "\",");
    console.log("JSONSUMMARY:   \"tokenTransferable\": \"" + contract.transferable() + "\",");
    console.log("JSONSUMMARY:   \"tokenMintable\": \"" + contract.mintable() + "\",");
    var startDate = contract.START_DATE();
    console.log("JSONSUMMARY:   \"crowdsaleStart\": " + startDate + ",");
    console.log("JSONSUMMARY:   \"crowdsaleStartString\": \"" + new Date(startDate * 1000).toString() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleStartUTCString\": \"" + new Date(startDate * 1000).toUTCString() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleClosed\": \"" + contract.closed() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleEthMinContribution\": " + contract.ethMinContribution() + ",");
    console.log("JSONSUMMARY:   \"crowdsaleTestContribution\": " + contract.TEST_CONTRIBUTION().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"crowdsaleUsdCap\": " + contract.usdCap() + ",");
    console.log("JSONSUMMARY:   \"crowdsaleEthCap\": " + contract.ethCap().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"crowdsaleUsdPerKEther\": " + contract.usdPerKEther() + ",");
    console.log("JSONSUMMARY:   \"crowdsaleContributedEth\": " + contract.contributedEth().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"crowdsaleContributedUsd\": " + contract.contributedUsd() + ",");
    console.log("JSONSUMMARY:   \"crowdsaleWhiteListAddress\": \"" + contract.whitelist() + "\",");
    console.log("JSONSUMMARY:   \"crowdsalePICOPSCertifier\": \"" + contract.picopsCertifier() + "\",");

    var separator = "";
    var fromBlock = 4731537;
    var contributedEvents = contract.Contributed({}, { fromBlock: fromBlock, toBlock: "latest" }).get();
    console.log("JSONSUMMARY:   \"numberOfContributions\": " + contributedEvents.length + ",");
    console.log("JSONSUMMARY:   \"contributions\": [");
    var accounts = {};
    for (var i = 0; i < contributedEvents.length; i++) {
      var e = contributedEvents[contributedEvents.length - 1 - i];
      var separator;
      if (i == contributedEvents.length - 1) {
        separator = "";
      } else {
        separator = ",";
      }
      accounts[e.args.addr] = accounts[e.args.addr] + 1;
      var ts = eth.getBlock(e.blockNumber).timestamp;
      console.log("JSONSUMMARY:     {");
      console.log("JSONSUMMARY:       \"address\": \"" + e.args.addr + "\",");
      console.log("JSONSUMMARY:       \"transactionHash\": \"" + e.transactionHash + "\",");
      console.log("JSONSUMMARY:       \"href\": \"https://etherscan.io/tx/" + e.transactionHash + "\",");
      console.log("JSONSUMMARY:       \"blockNumber\": " + e.blockNumber + ",");
      console.log("JSONSUMMARY:       \"transactionIndex\": " + e.transactionIndex + ",");
      console.log("JSONSUMMARY:       \"timestamp\": " + ts + ",");
      console.log("JSONSUMMARY:       \"timestampString\": \"" + new Date(ts * 1000).toString() + "\",");
      console.log("JSONSUMMARY:       \"timestampUTCString\": \"" + new Date(ts * 1000).toUTCString() + "\",");
      console.log("JSONSUMMARY:       \"ethAmount\": " + e.args.ethAmount.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"ethRefund\": " + e.args.ethRefund.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"usdAmount\": " + e.args.usdAmount + ",");
      console.log("JSONSUMMARY:       \"contributedEth\": " + e.args.contributedEth.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"contributedUsd\": " + e.args.contributedUsd + "");
      console.log("JSONSUMMARY:     }" + separator);
    }
    console.log("JSONSUMMARY:   ],");
    var accountKeys = Object.keys(accounts);
    accountKeys.sort();
    console.log("JSONSUMMARY:   \"numberOfAccounts\": " + accountKeys.length + ",");
    console.log("JSONSUMMARY:   \"accounts\": [");
    for (var i = 0; i < accountKeys.length; i++) {
      var separator;
      if (i == accountKeys.length - 1) {
        separator = "";
      } else {
        separator = ",";
      }
      console.log("JSONSUMMARY:       \"" + accountKeys[i] + "\"" + separator);
    }
    console.log("JSONSUMMARY:   ]");
  }
  console.log("JSONSUMMARY: }");
}

generateSummaryJSON();
EOF

mv tmp.json DeveryPresaleSummary.json
