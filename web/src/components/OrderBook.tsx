// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { HStack, VStack, Box } from '@chakra-ui/react'
import { BigNumber } from 'ethers';
import Order from './Order'

function OrderBook({provider, address, pair, myPos, sdenom, pdenom, oraclePrice, updateTrigger, triggerUpdate}) {
    const [bids, setBids] = React.useState([])
    const [offers, setOffers] = React.useState([])

    React.useEffect(() => {
        (async () => {
            if (!pair) return;
            await buildOrderBook();
        }) ();
    }, [provider, address, pair, updateTrigger]); // On load

    const buildOrderBook = async () => {
        const numItems = await pair.contract.numOrders();
        let blist = []
        let olist = []
        for (let i = BigNumber.from(0); i.lt(numItems); i = i.add(BigNumber.from(1))) {
            const order = {...(await pair.contract.orderStatus(i)), ...{orderId: i}};
            if (order.amount.gt(BigNumber.from(0))) blist.push(order)
            if (order.amount.lt(BigNumber.from(0))) olist.push(order)
            // if (order.amount.isZero()) ignore
        }
        blist.sort((a, b) => { return a.limitPrice.lt(b.limitPrice) ? 1 : -1 })
        olist.sort((a, b) => { return a.limitPrice.gt(b.limitPrice) ? 1 : -1 })
        setBids(blist);
        setOffers(olist);
    }

    return (<HStack width='100%' p={4} align='top'>
        <VStack width='50%' p={4} borderRadius='md' shadow='lg' bg='gray.50'>
        <Box>Bids:</Box>
        {bids.map((o)=><Order key={o.orderId} 
                            provider={provider} address={address} pair={pair} myPos={myPos} sdenom={sdenom} pdenom={pdenom} oraclePrice={oraclePrice} updateTrigger={updateTrigger} triggerUpdate={triggerUpdate}
                            order={o}/>)}
        </VStack>
        <VStack width='50%' p={4} borderRadius='md' shadow='lg' bg='gray.50'>
        <Box>Offers:</Box>
        {offers.map((o)=><Order key={o.orderId} 
                            provider={provider} address={address} pair={pair} myPos={myPos} sdenom={sdenom} pdenom={pdenom} oraclePrice={oraclePrice} updateTrigger={updateTrigger} triggerUpdate={triggerUpdate}
                            order={o}/>)}
        </VStack>
    </HStack>);
}

export default OrderBook;