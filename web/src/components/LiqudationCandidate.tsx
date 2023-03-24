// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Box, Button } from '@chakra-ui/react'
import { BigNumber } from 'ethers'
import uint256ToDecimal from '../utils/uint256ToDecimal';
import {
    Popover,
    PopoverTrigger,
    PopoverContent,
    PopoverHeader,
    PopoverBody,
    PopoverFooter,
    PopoverArrow,
    PopoverCloseButton,
    PopoverAnchor,
  } from '@chakra-ui/react'

function LiqudationCandidate({provider, address, pair, myPos, sdenom, pdenom, oraclePrice, updateTrigger, triggerUpdate, liquidationCandidate}) {
    const vdenom = BigNumber.from(10).pow(BigNumber.from(18))

    const liquidatePosition = async () => {
        try{
            const tx = await pair.contract.liquidate(liquidationCandidate.positionId);
            const r = await tx.wait();
            triggerUpdate()
            window.alert('Completed. Block hash: ' + r.blockHash);
         } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""));
        }
    }

    return (<Box width='100%' borderRadius='md' shadow='lg' bg='gray.100'>
        <Popover>
            <PopoverTrigger>
                <Box>
                Owner: {liquidationCandidate.owner.toString()} <br/>
                Holding: {uint256ToDecimal(liquidationCandidate.holding, vdenom)} <br/>
                Collateral shortage: {uint256ToDecimal(liquidationCandidate.liquidationCollateralLevel.sub(liquidationCandidate.collateral), sdenom)}               
                </Box>
            </PopoverTrigger>
            <PopoverContent>
                <PopoverArrow />
                <PopoverCloseButton />
                <PopoverHeader>
                    Liqudation
                </PopoverHeader>
                <PopoverBody><Box align='right'><Button onClick={liquidatePosition} colorScheme='blue'>Liquidate</Button></Box></PopoverBody>
            </PopoverContent>
        </Popover>        
    </Box>);
}

export default LiqudationCandidate;