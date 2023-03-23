// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { HStack, VStack } from '@chakra-ui/react'
import { BigNumber } from 'ethers';

function OrderBook({provider, address, pair, myPos, sdenom, pdenom, oraclePrice}) {
    const [bids, setBids] = React.useState([])
    const [offers, setOffers] = React.useState([])
    const [blockNumber, setBlockNumber] = React.useState(null);

    React.useEffect(() => {
        (async () => {
            if (!pair) return;
            await buildOrderBook();
        }) ();
    }, [provider, address, pair, blockNumber]); // On load

    const onUpdate = async (blockNumber) => {
        setBlockNumber(blockNumber)
    }

    const buildOrderBook = async () => {
        const numItems = await pair.contract.numOrders();
        let blist = []
        let olist = []
        for (let i = BigNumber.from(0); i.lt(numItems); i.add(BitNumber.from(1))) {
            order = await pair.contract.orderStatus(i);
            order.orderId = i;
            if (order.amount.gt(BigNumber.from(0))) blist.push(order)
            if (order.amount.lt(BigNumber.from(0))) olist.push(order)
            // if (order.amount.isZero()) ignore
        }
        blist.sort((a, b) => { return a.lt(b) ? 1 : -1 })
        olist.sort((a, b) => { return a.gt(b) ? 1 : -1 })
        setBids(blist);
        setOffers(olist);
    }

    return (<HStack>
        <VStack>
        {bids.map((o)=><Order key={o.orderId} 
                             provider={provider} address={address} pair={pair} myPos={myPos} sdenom={sdenom} pdenom={pdenom} oraclePrice={oraclePrice}
                             order={order}/>)}
        </VStack>
        <VStack>
        {bids.map((o)=><Order key={o.orderId} 
                             provider={provider} address={address} pair={pair} myPos={myPos} sdenom={sdenom} pdenom={pdenom} oraclePrice={oraclePrice}
                             order={order}/>)}
        </VStack>
    </HStack>);
}

export default OrderBook;