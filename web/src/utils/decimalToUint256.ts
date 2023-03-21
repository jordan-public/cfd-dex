// SPDX-License-Identifier: BUSL-1.1
import BigNumber from 'bignumber.js';

// denom : ethers.BigNumber
export default function decimalToUint256(d, denom) {
    if (denom.isZero()) return "";
    let bd = new BigNumber(d);
    bd = bd.multipliedBy(new BigNumber(denom.toString()));
    bd = bd.integerValue();
    BigNumber.config({ EXPONENTIAL_AT: 256 })
    return bd.toString();
}