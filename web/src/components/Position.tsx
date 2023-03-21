// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Text, Box, Stat, StatLabel, StatNumber, StatHelpText, StatArrow, StatGroup } from '@chakra-ui/react'
import { BigNumber } from 'ethers'
import uint256ToDecimal from '../utils/uint256ToDecimal';

function Position({provider, address, pair, myPos, denom, oraclePrice}) {
    return (<Box bg={myPos.collateral.lt(myPos.liquidationCollateralLevel) ? 'red.100' : 'green.100'} borderRadius='md' shadow='lg' align='center' p={6}><StatGroup gap={20}>
        <Stat>
          <StatNumber>{uint256ToDecimal(oraclePrice, denom)}</StatNumber>
          <StatLabel><Text fontWeight='bold' fontSize='xl'>{pair.Description}</Text> Oracle Price</StatLabel>
        </Stat>
      
        <Stat>
          <StatNumber>{uint256ToDecimal(myPos.holding, denom)}</StatNumber>
          <StatLabel>Holding</StatLabel>
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
            {uint256ToDecimal(myPos.unrealizedGain.mul(BigNumber.from(10000)).div(myPos.holding.abs()), BigNumber.from(100))} %
          </StatHelpText>}
          <StatLabel>Unrealized Gain</StatLabel>
        </Stat>
    </StatGroup></Box>);
}

export default Position;