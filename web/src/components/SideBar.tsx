// SPDX-License-Identifier: BUSL-1.1
import React from 'react';
import { Button, ButtonGroup } from '@chakra-ui/react'
import { ethers } from 'ethers';
import aCFDOrderBookFactory from '../artifacts/CFDOrderBookFactory.json';
import aICFDOrderBook from '../artifacts/ICFDOrderBook.json';
import aIERC20 from '../artifacts/IERC20.json';

function SideBar({provider, address, setPair}) {
    const [pairList, setPairList] = React.useState([]);

    const getOB = async (cICFDOrderBook) => {
        const signer = provider.getSigner()
        const obDescription = await cICFDOrderBook.getDescription()
        const scAddr = await cICFDOrderBook.settlementCurrency()
        const cSettlementCurrency = new ethers.Contract(scAddr, aIERC20.abi, signer)
        const scSymbol = await cSettlementCurrency.symbol()
        return {description: obDescription, contract: cICFDOrderBook, settlementCurrencyContract: cSettlementCurrency, settlementCurrencySymbol: scSymbol};
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
    return (
        <ButtonGroup gap='4' flexDirection='column' alignItems='center' margin={1}>
            <br/>
            {pairList.map((p) => <Button key={p.description} colorScheme='blue' size='sm' width='80%' align='center' onClick={()=>setPair(p)}>{p.description}</Button>)}
        </ButtonGroup>
    );
}

export default SideBar;