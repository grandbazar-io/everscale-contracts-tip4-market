# everscale-contracts-tip4-market

Customizable grandbazar.io contracts for NFT trading. Based on [Itgold](https://github.com/itgoldio/everscale-tip) standard. You can customize all contracts by extending them.

# What is needed for development?

- Install [Everdev](https://github.com/tonlabs/everdev)
- Install [Locklift](https://github.com/broxus/locklift)

# Build project

1. Copy ```locklift.config.template.ts``` into ```config.template.ts``` and configure it 
2. Run ```npx locklift build```

# Test

1. Start local node with ```everdev se start```
2. Run ```npm run test```

# Deploy

1. Run ```npm run deploy-sell``` and ```npm run deploy-auction``` for deploying to devnet
2. Run ```npm run deploy-sell-main``` and ```npm run deploy-auction-main``` for deploying to mainnet
