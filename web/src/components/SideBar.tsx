// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Button, ButtonGroup } from '@chakra-ui/react'
import { ethers } from 'ethers';
import aCFDOrderBookFactory from '../artifacts/CFDOrderBookFactory.json';
import aICFDOrderBook from '../artifacts/ICFDOrderBook.json';

function SideBar({provider, address, setPair}) {
    const [pairList, setPairList] = React.useState([]);

    const getOB = async (cICFDOrderBook) => {
        const signer = provider.getSigner();
        const obDescription = await cICFDOrderBook.getDescription();
        return {Description: obDescription, contract: cICFDOrderBook};
    }

    React.useEffect(() => {
        (async () => {
            if (!provider) return;
            const signer = provider.getSigner();
            const cCFDOrderBookFactory = new ethers.Contract(aCFDOrderBookFactory.contractAddress, aCFDOrderBookFactory.abi, signer);
            const numOBs = (await cCFDOrderBookFactory.getNumOBs()).toNumber();
            let p = [];
            for (let i=0; i<numOBs; i++) {
                const pairContractAddress = await cCFDOrderBookFactory.getOB(i);
                const cICFDOrderBook = new ethers.Contract(pairContractAddress, aICFDOrderBook.abi, signer);
                p.push(await getOB(cICFDOrderBook));
            } 
            setPairList(p);
        }) ();
    }, [provider, address]); // On load

    if (!provider) return <></>;
    return (<>
        <ButtonGroup gap='4' flexDirection='column' alignItems='center' margin={4}>
            {pairList.map((p) => <Button key={p.Description} colorScheme='blue' size='sm' onClick={()=>setPair(p)}>{p.Description}</Button>)}
        </ButtonGroup>
        </>);
}

export default SideBar;