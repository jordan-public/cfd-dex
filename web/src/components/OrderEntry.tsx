// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Button } from '@chakra-ui/react'

function OrderEntry({provider, address, pair}) {
    return (<>
        <Button>Make Bid</Button>
        <br/>
        <Button>Make Offer</Button>
    </>);
}

export default OrderEntry;