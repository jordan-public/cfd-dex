// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { VStack } from '@chakra-ui/react'
import Position from './Position'
import OrderEntry from './OrderEntry'
import OrderBook from './OrderBook'

function Body({provider, address, pair}) {
    if (!pair || !address) return <></>;
    return (<VStack>
        <Position provider={provider} address={address} pair={pair}/>
        <OrderEntry provider={provider} address={address} pair={pair}/>
        <OrderBook provider={provider} address={address} pair={pair}/>
    </VStack>);
}

export default Body;