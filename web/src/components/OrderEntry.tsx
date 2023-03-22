// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Box, NumberInput, NumberInputField, Button, HStack, Input } from '@chakra-ui/react'
import uint256ToDecimal from '../utils/uint256ToDecimal';

function OrderEntry({provider, address, pair, myPos, sdenom, pdenom, oraclePrice}) {
    const [value, setValue] = React.useState(0);
    const [amount, setAmount] = React.useState(0);
    const [limitPrice, setLimitPrice] = React.useState(0);

    React.useEffect(() => {
        setLimitPrice(parseFloat(uint256ToDecimal(oraclePrice, pdenom)));
    }, [pair, pdenom, oraclePrice])

    const onDeposit = async () => {

    }

    const onWithdraw = async () => {

    }

    const onWitdrawMax = async () => {

    }

    const onBid = async () => {

    }

    const onOffer = async () => {

    }

    return (<Box borderRadius='md' shadow='lg' align='center' p={6}>
        <HStack p={4}>
            <NumberInput  value={value} onChange={v => setValue(parseFloat(v))} precision={2}>
                <NumberInputField/>
            </NumberInput>
            <Button onClick={onDeposit}>Deposit</Button>
            <Button onClick={onWithdraw}>Withdraw</Button>
            <Button onClick={onWitdrawMax}>Withdraw Max.</Button>
        </HStack>
        <HStack p={4}>
            <NumberInput  value={amount} onChange={v => setAmount(parseFloat(v))} precision={2}>
                <NumberInputField/>
            </NumberInput>
            <NumberInput value={limitPrice} onChange={v => setLimitPrice(parseFloat(v))} precision={6}>
                <NumberInputField />
            </NumberInput>
            <Button onClick={onBid}>Bid</Button>
            <Button onClick={onOffer}>Offer</Button>
        </HStack>
        {limitPrice}
    </Box>);
}

export default OrderEntry;