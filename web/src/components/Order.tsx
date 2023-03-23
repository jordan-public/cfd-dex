// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Box, Tooltip } from '@chakra-ui/react'
import { BigNumber } from 'ethers'
import uint256ToDecimal from '../utils/uint256ToDecimal';

function Order({provider, address, pair, myPos, sdenom, pdenom, oraclePrice, order}) {
    const vdenom = BigNumber.from(10).pow(BigNumber.from(18))

    const onOrderClicked = async () => {
        if (address.toLowerCase() === order.owner.toString().toLowerCase()) {
            await cancelOrder(order.orderId)
        }
    }

    const cancelOrder = async (orderId) => {
        try{
            const tx = await pair.contract.cancel(orderId);
            const r = await tx.wait();
            window.alert('Completed. Block hash: ' + r.blockHash);
         } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""));
        }
    }

    return (<Box width='100%' borderRadius='md' shadow='lg' bg={order.amount.lt(BigNumber.from(0)) ? 'red.50' : 'green.50'} onClick={onOrderClicked}>
        <Tooltip label={"Id: " + order.orderId.toString() + " Issuer: " + order.owner.toString()} aria-label='A tooltip'>
            {uint256ToDecimal(order.amount.abs(), vdenom) + " @ " + uint256ToDecimal(order.limitPrice, pdenom)}
        </Tooltip>
    </Box>);
}

export default Order;