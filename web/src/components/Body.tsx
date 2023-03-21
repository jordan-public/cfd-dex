// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { VStack } from '@chakra-ui/react'
import Position from './Position'
import OrderEntry from './OrderEntry'
import OrderBook from './OrderBook'
import { BigNumber } from 'ethers'

function Body({provider, address, pair}) {
    const [myPos, setMyPos] = React.useState(null);
    const [denom, setDenom] = React.useState(BigNumber.from(0));
    const [oraclePrice, setOraclePrice] = React.useState(BigNumber.from(0));


    React.useEffect(() => {
        (async () => {
            if (!pair) return;
            setMyPos(await pair.contract.getMyPosition());
            setDenom(await pair.contract.settlementCurrencyDenominator());
            setOraclePrice(await pair.contract.getPrice());
        }) ();
    }, [provider, address, pair]); // On load

    if (!address || !pair || !myPos || denom.isZero() || oraclePrice.isZero()) return(<></>);
    return (<VStack>
        <br/>
        <Position provider={provider} address={address} pair={pair} myPos={myPos} denom={denom} oraclePrice={oraclePrice}/>
        <OrderEntry provider={provider} address={address} pair={pair} myPos={myPos} denom={denom} oraclePrice={oraclePrice}/>
        <OrderBook provider={provider} address={address} pair={pair} myPos={myPos} denom={denom} oraclePrice={oraclePrice}/>
    </VStack>);
}

export default Body;