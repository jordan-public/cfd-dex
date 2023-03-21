// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Box, NumberInput, NumberInputField, Button, HStack } from '@chakra-ui/react'
import uint256ToDecimal from '../utils/uint256ToDecimal';

function OrderEntry({provider, address, pair, myPos, denom, oraclePrice}) {
    return (<Box borderRadius='md' shadow='lg' align='center' p={6}>
        <HStack p={4}>
            <NumberInput defaultValue={0} precision={2} step={0.2}>
                <NumberInputField />
            </NumberInput>
            <Button>Deposit</Button>
            <Button>Withdraw</Button>
            <Button>Withdraw Max.</Button>
        </HStack>
        <HStack p={4}>
            <NumberInput defaultValue={0} precision={2} step={0.2}>
                <NumberInputField />
            </NumberInput>
            <NumberInput defaultValue={parseFloat(uint256ToDecimal(oraclePrice, denom))} precision={6} step={0.2}>
                <NumberInputField />
            </NumberInput>
            <Button>Bid</Button>
            <Button>Offer</Button>
        </HStack>
    </Box>);
}

export default OrderEntry;