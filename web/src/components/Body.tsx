// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { VStack } from '@chakra-ui/react'
import Position from './Position'
import OrderEntry from './OrderEntry'
import OrderBook from './OrderBook'
import { BigNumber } from 'ethers'

function Body({provider, address, pair}) {
    const [myPos, setMyPos] = React.useState(null);
    const [sdenom, setSDenom] = React.useState(BigNumber.from(0));
    const [pdenom, setPDenom] = React.useState(BigNumber.from(0));
    const [oraclePrice, setOraclePrice] = React.useState(BigNumber.from(0));
    const [blockNumber, setBlockNumber] = React.useState(null);

    React.useEffect(() => {
        (async () => {
            if (!pair) return;
            setMyPos(await pair.contract.getMyPosition());
            setSDenom(await pair.contract.settlementCurrencyDenominator());
            setPDenom(await pair.contract.priceDenominator());
            setOraclePrice(await pair.contract.getPrice());
        }) ();
    }, [provider, address, pair]); // On load

    React.useEffect(() => {
        (async () => {
            if (!pair) return;
            setMyPos(await pair.contract.getMyPosition());
            setOraclePrice(await pair.contract.getPrice());
        }) ();
    }, [provider, address, pair, blockNumber]); // On load

    const onUpdate = async (blockNumber) => {
// console.log("Block ", blockNumber);
        setBlockNumber(blockNumber)
    }

    React.useEffect(() => {
        if (provider) {
            provider.on("block", onUpdate);
            return () => provider.off("block", onUpdate);
        }
    }, []); // Run on each render because onUpdate is a closure

    if (!address || !pair || !myPos || sdenom.isZero() || pdenom.isZero() || oraclePrice.isZero()) return(<></>);
    return (<VStack>
        <br/>
        <Position provider={provider} address={address} pair={pair} myPos={myPos} sdenom={sdenom} pdenom={pdenom} oraclePrice={oraclePrice}/>
        <OrderEntry provider={provider} address={address} pair={pair} myPos={myPos} sdenom={sdenom} pdenom={pdenom} oraclePrice={oraclePrice}/>
        <OrderBook provider={provider} address={address} pair={pair} myPos={myPos} sdenom={sdenom} pdenom={pdenom} oraclePrice={oraclePrice}/>
    </VStack>);
}

export default Body;