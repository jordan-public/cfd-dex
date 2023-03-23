// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Box } from '@chakra-ui/react'
import uint256ToDecimal from '../utils/uint256ToDecimal';

function Order({provider, address, pair, myPos, sdenom, pdenom, oraclePrice, order}) {
    const vdenom = BigNumber.from(10).pow(BigNumber.from(18))

    return (<Box>
        OrderId: {order.orderId.toString()} <br/>
        Amount: {uint256ToDecimal(order.amount, vdenom)} <br/>
        Limit price: {uint256ToDecimal(order.limitPrice, pdenom)} <br/>
        Owner: {order.owner.toString()}
    </Box>);
}

export default Order;