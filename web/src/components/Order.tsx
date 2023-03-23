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
  import {
    Slider,
    SliderTrack,
    SliderFilledTrack,
    SliderThumb,
    SliderMark,
  } from '@chakra-ui/react'

function Order({provider, address, pair, myPos, sdenom, pdenom, oraclePrice, blockNumber, order}) {
    const vdenom = BigNumber.from(10).pow(BigNumber.from(18))

    const onOrderClicked = async () => {
        if (address.toLowerCase() === order.owner.toString().toLowerCase()) {
            await cancelOrder(order.orderId)
        }
    }

    const cancelOrder = async () => {
        try{
            const tx = await pair.contract.cancel(order.orderId);
            const r = await tx.wait();
            window.alert('Completed. Block hash: ' + r.blockHash);
         } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""));
        }
    }

    const takeOrder = async (sliderValue) => {
        try{
            const tx = await pair.contract.take(order.orderId, BigNumber.from(0).sub(order.amount).mul(BigNumber.from(sliderValue)).div(BigNumber.from(100)));
            const r = await tx.wait();
            window.alert('Completed. Block hash: ' + r.blockHash);
         } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""));
        }
    }

    const Body = () => {
        const [sliderValue, setSliderValue] = React.useState(100)

        if (address.toLowerCase() === order.owner.toString().toLowerCase()) {
            return (<Box align='right'><Button onClick={cancelOrder} colorScheme='blue'>Cancel order</Button></Box>)
        }
        return(<Box pt={6} pb={2} align='right'>
            <Slider defaultValue={100} aria-label='slider-ex-6' onChange={(val) => setSliderValue(val)}>
                <SliderMark
                value={sliderValue}
                textAlign='center'
                bg='blue.500'
                color='white'
                mt='-10'
                ml='-5'
                w='12'
                >
                {sliderValue}%
                </SliderMark>
                <SliderTrack>
                <SliderFilledTrack />
                </SliderTrack>
                <SliderThumb />
            </Slider>
            <br/>
            <Button onClick={() => takeOrder(sliderValue)} colorScheme='blue'>Take</Button>
        </Box>)
    }

    return (<Box width='100%' borderRadius='md' shadow='lg' bg={order.amount.lt(BigNumber.from(0)) ? 'red.50' : 'green.50'}>
        <Popover>
            <PopoverTrigger>
                <Box>
                    {uint256ToDecimal(order.amount.abs(), vdenom) + " @ " + uint256ToDecimal(order.limitPrice, pdenom) + (address.toLowerCase() === order.owner.toString().toLowerCase() ? " (me)" : "")}
                </Box>
            </PopoverTrigger>
            <PopoverContent>
                <PopoverArrow />
                <PopoverCloseButton />
                <PopoverHeader>
                    {uint256ToDecimal(order.amount.abs(), vdenom) + " @ " + uint256ToDecimal(order.limitPrice, pdenom)}
                    Id: {order.orderId.toString()} <br/> 
                    Issuer: {order.owner.toString() + (address.toLowerCase() === order.owner.toString().toLowerCase() ? " (me)" : "")}
                </PopoverHeader>
                <PopoverBody><Body/></PopoverBody>
            </PopoverContent>
        </Popover>        
    </Box>);
}

export default Order;