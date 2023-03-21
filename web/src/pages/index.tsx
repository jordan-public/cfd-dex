import Head from 'next/head'
import Image from 'next/image'
import { Inter } from '@next/font/google'
import styles from '@/styles/Home.module.css'
import React from 'react'
import { Flex, Box, Grid, GridItem } from '@chakra-ui/react'
import NavigationBar from '@/components/NavigationBar'
import SideBar from '@/components/SideBar'
import Body from '@/components/Body'

const inter = Inter({ subsets: ['latin'] })

export default function Home() {
  const [provider, setProvider] = React.useState(null);
  const [address, setAddress] = React.useState(null);
  const [pair, setPair] = React.useState(null);

  return (
    <>
      <Head>
        <title>CFD DEX</title>
        <meta name="description" content="Contracts for Difference Decentralized Exchange (CFD DEX)" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <main className={styles.main}>
        <Grid width='100%'>
          <GridItem rowStart={1} colStart={1} colSpan={20}>
            <NavigationBar provider={provider} setProvider={setProvider} address={address} setAddress={setAddress} />
          </GridItem>
          <GridItem rowStart={2} colSpan={1} bg='gray.50'>
            <SideBar provider={provider} address={address} setPair={setPair}/>
          </GridItem>
          <GridItem rowStart={2} colSpan={19} bg='green.50'>
            <Body provider={provider} address={address} pair={pair}/>
          </GridItem>
        </Grid>    
      </main>
    </>
  )
}
