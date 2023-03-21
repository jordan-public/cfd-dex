// SPDX-License-Identifier: BUSL-1.1
import BigNumber from 'bignumber.js';

// denom : ethers.BigNumber
export default function uint256ToDecimal(u, denom) {
    if (denom.isZero()) return "";
    let bd = new BigNumber(u.toString());
    bd = bd.dividedBy(new BigNumber(denom.toString()));
    BigNumber.config({ EXPONENTIAL_AT: 256 })
    return bd.toString();
}