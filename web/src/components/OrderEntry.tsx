// SPDX-License-Identifier: BUSL-1.1
import React from 'react'
import { Box, NumberInput, NumberInputField, Button, HStack } from '@chakra-ui/react'
import uint256ToDecimal from '../utils/uint256ToDecimal'
import decimalToUint256 from '../utils/decimalToUint256'
import aIERC20 from '../artifacts/IERC20.json'
import { ethers, BigNumber } from 'ethers'

function OrderEntry({provider, address, pair, myPos, sdenom, pdenom, oraclePrice}) {
    const vdenom = BigNumber.from(10).pow(BigNumber.from(18))
    const [value, setValue] = React.useState(0)
    const [amount, setAmount] = React.useState(0)
    const [limitPrice, setLimitPrice] = React.useState(0)
    const [settlementCurrencyContract, setSettlementCurrencyContract] = React.useState(null)

    React.useEffect(() => {
        setLimitPrice(parseFloat(uint256ToDecimal(oraclePrice, pdenom)));
    }, [pair, pdenom, oraclePrice])

    React.useEffect(() => {
        (async () => {const scAddr = await pair.contract.settlementCurrency();
        const signer = provider.getSigner();
        setSettlementCurrencyContract(new ethers.Contract(scAddr, aIERC20.abi, signer));
        }) ();
    }, [pair.contract, provider]);

    const authorizeIfNeeded = async () => {
        const a = await settlementCurrencyContract.allowance(address, pair.contract.address)
        const needed = BigNumber.from(decimalToUint256(value, sdenom))
        if (a.gte(needed)) return a
        try{
            const tx = await settlementCurrencyContract.approve(pair.contract.address, needed)
            const r = await tx.wait()
            window.alert('Completed. Block hash: ' + r.blockHash)
            return needed
        } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""))
            return 0
        }
    }

    const onDeposit = async () => {
        if (await authorizeIfNeeded() === 0) return;
        try{
            const tx = await pair.contract.deposit(BigNumber.from(decimalToUint256(value, sdenom)))
            const r = await tx.wait()
            window.alert('Completed. Block hash: ' + r.blockHash)
         } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""))
        }
    }

    const onWithdraw = async () => {
        try{
            const tx = await pair.contract.withdraw(BigNumber.from(decimalToUint256(value, sdenom)))
            const r = await tx.wait()
            window.alert('Completed. Block hash: ' + r.blockHash)
         } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""))
        }
    }

    const onWitdrawMax = async () => {
        try{
            const tx = await pair.contract.withdrawMax();
            const r = await tx.wait();
            window.alert('Completed. Block hash: ' + r.blockHash);
         } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""));
        }
    }

    const make = async (a) => {
        try{
            const tx = await pair.contract.make(BigNumber.from(decimalToUint256(a, vdenom)), BigNumber.from(decimalToUint256(limitPrice, pdenom)));
            const r = await tx.wait();
            window.alert('Completed. Block hash: ' + r.blockHash);
         } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""));
        }
    }

    const onBid = async () => {
        await make(amount);
    }

    const onOffer = async () => {
        await make(-amount);
    }

    if (!settlementCurrencyContract) return(<></>)
    return (<Box borderRadius='md' shadow='lg' align='center' p={6}>
        <HStack p={4}>
            <NumberInput  value={value} onChange={v => setValue(parseFloat(v))} precision={2}>
                <NumberInputField/>
            </NumberInput>
            <Button onClick={onDeposit} colorScheme='green'>Deposit</Button>
            <Button onClick={onWithdraw} colorScheme='red'>Withdraw</Button>
            <Button onClick={onWitdrawMax} colorScheme='red'>Withdraw Max.</Button>
        </HStack>
        <HStack p={4}>
            <NumberInput  value={amount} onChange={v => setAmount(parseFloat(v))} precision={2}>
                <NumberInputField/>
            </NumberInput>
            <NumberInput value={limitPrice} onChange={v => setLimitPrice(parseFloat(v))} precision={6}>
                <NumberInputField />
            </NumberInput>
            <Button onClick={onBid} colorScheme='green'>Bid</Button>
            <Button onClick={onOffer} colorScheme='red'>Offer</Button>
        </HStack>
    </Box>);
}

export default OrderEntry;