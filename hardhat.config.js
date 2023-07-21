require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

const INFURA_API_KEY = process.env.INFURA_API_KEY
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY
const PRIVATE_KEY = process.env.PRIVATE_KEY
const ABI = process.env.ABI
const TARGET = process.env.TARGET
const NETWORK = process.env.NETWORK

console.log(`INFURA_API_KEY=${INFURA_API_KEY}`);
console.log(`ALCHEMY_API_KEY=${ALCHEMY_API_KEY}`);

task("KottageFactoryCreate")
  .addOptionalParam("abi", "ABI", `${ABI}`)
  .addOptionalParam("contract", "Target contract", `${TARGET}`)
  .addParam("name")
  .addParam("symbol")
  .addParam("uri")
  .addParam("owner")
  .setAction(async (taskArgs) => {
    const Factory = await ethers.getContractFactory(taskArgs.abi);
    const contract = await Factory.attach(taskArgs.contract);

    const result = await contract.createKottageToken(taskArgs.name, taskArgs.symbol, taskArgs.uri, taskArgs.owner);

    console.log(`KottageToken ${taskArgs.name} with owner ${taskArgs.owner} deployed at: ${result}`);
});


task("721_balanceOf")
  .addOptionalParam("abi", "ABI", `${ABI}`)
  .addOptionalParam("contract", "Target contract", `${TARGET}`)
  .addParam("owner")
  .setAction(async (taskArgs) => {
    const Factory = await ethers.getContractFactory(taskArgs.abi);
    const contract = await Factory.attach(taskArgs.contract);

    const balance = await contract.balanceOf(taskArgs.owner);
    console.log(`Balance is: ${balance}`);
});


task("721_symbol")
  .addParam("abi")
  .addParam("contract")
  .setAction(async (taskArgs) => {
    console.log(1)
    const Factory = await ethers.getContractFactory(taskArgs.abi);
    console.log(1)
    const contract = await Factory.attach(taskArgs.contract);
    console.log(1)

    const res = await contract.symbol();
    console.log(1)
    console.log(`Balance is: ${res}`);
});


task("721_name")
  .addParam("abi")
  .addParam("contract")
  .setAction(async (taskArgs) => {
    const Factory = await ethers.getContractFactory(taskArgs.abi);
    const contract = await Factory.attach(taskArgs.contract);

    const res = await contract.name();
    console.log(`Balance is: ${res}`);
});


task("721_ownerOf")
  .addParam("abi")
  .addParam("contract")
  .addParam("id")
  .setAction(async (taskArgs) => {
    const Factory = await ethers.getContractFactory(taskArgs.abi);
    const contract = await Factory.attach(taskArgs.contract);

    const result = await contract.ownerOf(taskArgs.id);
    console.log(`Owner is: ${result}`);
});

task("721_safeMint")
  .addParam("abi")
  .addParam("contract")
  .addParam("to")
  .addParam("uri")
  .setAction(async (taskArgs) => {
    const Factory = await ethers.getContractFactory(taskArgs.abi);
    const contract = await Factory.attach(taskArgs.contract);

    const result = await contract.safeMint(taskArgs.to, taskArgs.uri);
    console.log(`Result is: ${result}`);
});


task("721_tokenURI")
  .addParam("abi")
  .addParam("contract")
  .addParam("id")
  .setAction(async (taskArgs) => {
    const Factory = await ethers.getContractFactory(taskArgs.abi);
    const contract = await Factory.attach(taskArgs.contract);

    const result = await contract.tokenURI(taskArgs.id);
    console.log(`Result is: ${result}`);
});


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
        iRinkeby: {
            url: `https://rinkeby.infura.io/v3/${INFURA_API_KEY}`,
            accounts: [PRIVATE_KEY],
        },
        iGoerli: {
            url: `https://goerli.infura.io/v3/${INFURA_API_KEY}`,
            accounts: [PRIVATE_KEY],
        },
        iSepolia: {
            url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
            accounts: [PRIVATE_KEY],
        },
        iAvalanche: {
            url: `https://avalanche-mainnet.infura.io/v3/${INFURA_API_KEY}`,
            accounts: [PRIVATE_KEY],
        },
        iFuji: {
            url: `https://avalanche-fuji.infura.io/v3/${INFURA_API_KEY}`,
            accounts: [PRIVATE_KEY],
        },
        aGoerli: {
            url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
            accounts: [PRIVATE_KEY],
        },
        aOptimismGoerli: {
            url: `https://opt-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
            accounts: [PRIVATE_KEY],
        },
  },
};
