// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Box, Stat, StatLabel, StatNumber, StatHelpText, StatArrow, StatGroup } from '@chakra-ui/react'
import { BigNumber } from 'ethers'
import uint256ToDecimal from '../utils/uint256ToDecimal';

function Position({provider, address, pair}) {
    const [myPos, setMyPos] = React.useState(null);
    const [denom, setDenom] = React.useState(BigNumber.from(0));


    React.useEffect(() => {
        (async () => {
            if (!pair) return;
            setMyPos(await pair.contract.getMyPosition());
            setDenom(await pair.contract.settlementCurrencyDenominator());
        }) ();
    }, [provider, address, pair]); // On load

    if (!pair || !myPos || denom.isZero()) return(<></>);
    return (<Box bg='gray.50' borderRadius='md' shadow='lg' align='center' p={6}><StatGroup gap={20}>
        <Stat>
          <StatNumber>{uint256ToDecimal(myPos.holding, denom)}</StatNumber>
          <StatLabel>{pair.Description} Holding</StatLabel>
        </Stat>
      
        <Stat>
          <StatNumber>{uint256ToDecimal(myPos.holdingAveragePrice, denom)}</StatNumber>
          <StatLabel>Avg. Price</StatLabel>
        </Stat>

        <Stat>
          <StatNumber>{uint256ToDecimal(myPos.collateral, denom)}</StatNumber>
          <StatLabel>Collateral</StatLabel>
        </Stat>

        <Stat>
          <StatNumber>{uint256ToDecimal(myPos.liquidationCollateralLevel, denom)}</StatNumber>
          <StatLabel>Liq. Price</StatLabel>
        </Stat>

        <Stat>
          <StatNumber>{uint256ToDecimal(myPos.unrealizedGain, denom)}</StatNumber>
          { !myPos.holding.isZero() && <StatHelpText>
            <StatArrow type={myPos.unrealizedGain.gte(BigNumber.from(0)) ? 'increase' : 'decrease'} />
            {uint256ToDecimal(myPos.unrealizedGain.mul(BigNumber.from(10000)).div(myPos.holding), BigNumber.from(100))} %
          </StatHelpText>}
          <StatLabel>Unrealized Gain</StatLabel>
        </Stat>
    </StatGroup></Box>);
}

export default Position;