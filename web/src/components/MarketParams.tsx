// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Box, Stat, StatLabel, StatNumber, StatGroup } from '@chakra-ui/react'
import { BigNumber } from 'ethers'
import uint256ToDecimal from '../utils/uint256ToDecimal';

function MarketParams({provider, address, pair, myPos, sdenom, pdenom, oraclePrice, updateTrigger, triggerUpdate}) {
    const vdenomperc = BigNumber.from(10).pow(BigNumber.from(18))
    const vdenom = BigNumber.from(10).pow(BigNumber.from(18))
    const [entryMargin, setEntryMargin] = React.useState(null);
    const [maintenanceMargin, setMaintenanceMargin] = React.useState(null);
    const [liquidationPentalty, setLiquidationPentalty] = React.useState(null);
    const [dust, setDust] = React.useState(null);

    React.useEffect(() => {
        (async () => {
            if (!pair) return;
            setEntryMargin(uint256ToDecimal(await pair.contract.entryMargin(), vdenomperc) + "%");
            setMaintenanceMargin(uint256ToDecimal(await pair.contract.maintenanceMargin(), vdenomperc) + "%");
            setLiquidationPentalty(uint256ToDecimal(await pair.contract.liquidationPentalty(), vdenomperc) + "%");
            setDust(uint256ToDecimal(await pair.contract.dust(), vdenom));
        }) ()
    }, [pair]);

    if (!entryMargin || !maintenanceMargin || !liquidationPentalty || !dust) return <></>
    return (<Box bg='gray.50' borderRadius='md' shadow='lg' align='center' p={6}><StatGroup gap={20}>
        <Stat>
          <StatNumber>{entryMargin}</StatNumber>
          <StatLabel>Entry margin requirement</StatLabel>
        </Stat>
      
        <Stat>
          <StatNumber>{maintenanceMargin}</StatNumber>
          <StatLabel>Maintenance margin</StatLabel>
        </Stat>
      
        <Stat>
          <StatNumber>{liquidationPentalty}</StatNumber>
          <StatLabel>Liquidation penalty</StatLabel>
        </Stat>

        <Stat>
          <StatNumber>{dust}</StatNumber>
          <StatLabel>{"Min. trade size (" + pair.Description + ")"}</StatLabel>
        </Stat>
    </StatGroup></Box>);
}

export default MarketParams;