// SPDX-License-Identifier: BUSL-1.1
import BigNumber from 'bignumber.js';

export default function uint256ToDecimal(u, decimals) {
    if (decimals === null) return "";
    let bd = new BigNumber(u.toString());
    bd = bd.dividedBy(new BigNumber(10).exponentiatedBy(new BigNumber(decimals)));
    BigNumber.config({ EXPONENTIAL_AT: 256 })
//console.log("uint256ToDecimal", u, bd.toString());
    return bd.toString();
}