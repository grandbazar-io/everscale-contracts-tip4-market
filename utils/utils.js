const {
    builderOpInteger,
    builderOpCell,
    builderOpCellBoc,
    builderOpBitString,
    builderOpAddress,
} = require("@tonclient/core");

const u = (size, x) => {
    if (size === 256) {
      return builderOpBitString(`x${BigInt(x).toString(16).padStart(64, "0")}`);
    } else {
      return builderOpInteger(size, x);
    }
};

const u8 = (x) => u(8, x);
const u32 = (x) => u(32, x);
const u128 = (x) => u(128, x);
const u256 = (x) => u(256, x);
const b0 = u(1, 0);
const b1 = u(1, 0);
const bits = (x) => builderOpBitString(x);

module.exports = { u8, u32, u128, u256, b0, b1, bits };