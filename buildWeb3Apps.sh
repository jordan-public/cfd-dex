source push_artifacts.sh "DeployGnosisChiado.s.sol/10200"
cd web
pnpm run build
cd ..
mv web/out tmp/web.gnosis

source push_artifacts.sh "DeployMantleTestnet.s.sol/5001"
cd web
pnpm run build
cd ..
mv web/out tmp/web.mantle

source push_artifacts.sh "DeployOptimismGoerli.s.sol/420"
cd web
pnpm run build
cd ..
mv web/out tmp/web.optimism

source push_artifacts.sh "DeployScrollAlpha.s.sol/534353"
cd web
pnpm run build
cd ..
mv web/out tmp/web.scroll

source push_artifacts.sh "DeployTaikoAlpha-2.s.sol/167004"
cd web
pnpm run build
cd ..
mv web/out tmp/web.taiko

source push_artifacts.sh "DeployZkevmTestnet.s.sol/1442"
cd web
pnpm run build
cd ..
mv web/out tmp/web.zkevm

# ./push_artifacts.sh "DeployZksyncEraTestnet.s.sol/280"
# cd web
# pnpm run build
# cd ..
# mv web/out tmp/web.zksync

