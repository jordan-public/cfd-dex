// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Stat, StatLabel, StatNumber, StatHelpText, StatArrow, StatGroup } from '@chakra-ui/react'
import { BigNumber } from 'ethers'

function Position({provider, address, pair}) {
    const [myPos, setMyPos] = React.useState(null);

    React.useEffect(() => {
        (async () => {
            if (!pair) return;
            const myPos = (await pair.contract.getMyPosition());
            setMyPos(myPos);
        }) ();
    }, [provider, address, pair]); // On load

    if (!pair || !myPos) return(<></>);
    return (<StatGroup>
        <Stat>
          <StatLabel>{pair.Description} Holding</StatLabel>
          <StatNumber>{myPos.holding.toString()}</StatNumber>
        </Stat>
      
        <Stat>
          <StatLabel>Avg. Price</StatLabel>
          <StatNumber>{myPos.holdingAveragePrice.toString()}</StatNumber>
        </Stat>

        <Stat>
          <StatLabel>Collateral</StatLabel>
          <StatNumber>{myPos.collateral.toString()}</StatNumber>
        </Stat>

        <Stat>
          <StatLabel>Liq. Price</StatLabel>
          <StatNumber>{myPos.liquidationCollateralLevel.toString()}</StatNumber>
        </Stat>

        <Stat>
          <StatLabel>Unrealized Gain</StatLabel>
          <StatNumber>{myPos.unrealizedGain.toString()}</StatNumber>
          { !myPos.holding.isZero() && <StatHelpText>
            <StatArrow type={myPos.unrealizedGain.gte(BigNumber.from(0)) ? 'increase' : 'decrease'} />
            {myPos.unrealizedGain.mul(BigNumber.from(100)).div(myPos.holding).toString()} %
          </StatHelpText>}
        </Stat>
    </StatGroup>);
}

export default Position;