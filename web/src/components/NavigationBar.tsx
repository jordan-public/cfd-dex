// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Flex, Box, Text } from '@chakra-ui/react'
//import 'bootstrap/dist/css/bootstrap.css';
//import { Navbar } from 'react-bootstrap';
import Account from './Account';

function NavigationBar({provider, setProvider, address, setAddress}) {
    return (
        <Flex bg='gray.100' width='100%' justify='space-between' borderRadius='md' shadow='lg' align='center' p={2}>
            <Text fontWeight='bold'>CFD DEX</Text>
            <Box><Account provider={provider} setProvider={setProvider} address={address} setAddress={setAddress}/></Box>
        </Flex>
    );
}

export default NavigationBar;