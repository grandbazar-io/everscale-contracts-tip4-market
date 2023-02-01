const {
  SellRootContract,
} = require("../build/SellRootContract");
const { SellContract } = require("../build/SellContract");
const { AuctionRootContract } = require("../build/AuctionRootContract");
const { AuctionContract } = require("../build/AuctionContract");
const { SellProxyContract } = require("../build/SellProxyContract");

const config = {
  contracts: {
    SellRootContract,
    SellContract,
    AuctionRootContract,
    AuctionContract,
    SellProxyContract
  },
  whiteListAddresses: [process.env.WHITE_LIST_ADDRESS]
};

module.exports = { config };
