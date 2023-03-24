# How to install and run

## CFD-DEX with web front end

Go to any folder on a Linux or Mac OS machine:

Clone the repository and build:
```
git clone https://github.com/jordan-public/cfd-dex.git
cd cfd-dex
forge compile
cd web
pnpm i
```

Copy the fil ".env.example" to ".env":
```
cp .env.example .env
```
and edit it to your needs. If you have the passphrase, the easiest way to do this is to run the next command below, and Anvil will print the desired private key and address needed above.

In one shell in the folder cfd-dex run the forked blockchain node:
```
./anvil.sh
```

In another shell in the folder cfd-dex deploy the contracts, and then run the font-end server:
```
./deployAnvil.sh
cd web
pnpn run dev
```

Use a browser (prefferrably with MetaMask web3 extension installed) and go to the following URL: 
```
localhost:3000
```

## Flash Collateral demo

After the above, in the folder cfd-dex run:
```
./test.sh
```

Observe the test named "testFlashTrillionCollateral()".
