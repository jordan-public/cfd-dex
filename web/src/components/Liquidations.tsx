// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { HStack, VStack, Box } from '@chakra-ui/react'
import { BigNumber } from 'ethers';
import LiqudationCandidate from './LiqudationCandidate'

function Liquidations({provider, address, pair, myPos, sdenom, pdenom, oraclePrice, blockNumber}) {
    const [liquidationList, setLiquidationList] = React.useState([])

    React.useEffect(() => {
        (async () => {
            if (!pair) return;
            await buildLiquidationCandidatesList();
        }) ();
    }, [provider, address, pair, blockNumber]); // On load

    const buildLiquidationCandidatesList = async () => {
        const numItems = await pair.contract.numPositions();
        let list = []
        for (let i = BigNumber.from(0); i.lt(numItems); i = i.add(BigNumber.from(1))) {
            const position = await pair.contract.getPosition(i)
            if (position.collateral.lt(position.liquidationCollateralLevel)) list.push(position)
        }
        setLiquidationList(list);
    }

    return (<HStack width='100%' p={4} align='top'>
        <VStack width='100%' p={4} borderRadius='md' shadow='lg' bg='gray.50'>
        <Box>Liquidation candidates:</Box>
        {liquidationList.map((p)=><Order key={p.positionOwner} 
                             provider={provider} address={address} pair={pair} myPos={myPos} sdenom={sdenom} pdenom={pdenom} oraclePrice={oraclePrice} blockNumber={blockNumber}
                             liquidationCandidate={p}/>)}
        </VStack>
    </HStack>);
}

export default Liquidations;