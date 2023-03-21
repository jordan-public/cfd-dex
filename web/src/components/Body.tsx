// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Button, ButtonGroup } from '@chakra-ui/react'
import { ethers } from 'ethers';
import aICFDOrderBook from '../artifacts/ICFDOrderBook.json';

function Body({provider, address, pair}) {
    const [myPos, setMyPos] = React.useState(null);

    React.useEffect(() => {
        (async () => {
            if (!pair) return;
            const myPos = (await pair.contract.getMyPosition());
console.log("myPos: ", myPos);
            setMyPos(myPos);
        }) ();
    }, [provider, address, pair]); // On load

    if (!pair) return <></>;
    return (<>
        {pair && pair.Description} <br/>
        Position: {myPos && myPos.holding.toString() } <br/>
        <Button>Make Bid</Button>
        <br/>
        <Button>Make Offer</Button>
        </>);
}

export default Body;