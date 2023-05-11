require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  solidity: "0.8.4",
  networks: {
    hardhat: {
      chainId: 31337,
      forking: {
        url: "https://opt-mainnet.g.alchemy.com/v2/s1iBLxT-6zJW5Jt2DJycUNwxYp9udR8y", /*"https://opt-mainnet.g.alchemy.com/v2/s1iBLxT-6zJW5Jt2DJycUNwxYp9udR8y",*/
      },
    },
    optimism:
    {
      chainId: 31337,
      forking: {
        url: "https://opt-mainnet.g.alchemy.com/v2/s1iBLxT-6zJW5Jt2DJycUNwxYp9udR8y",
      },
      url: "https://opt-mainnet.g.alchemy.com/v2/s1iBLxT-6zJW5Jt2DJycUNwxYp9udR8y",
      accounts: [process.env.PRIVATE_KEY1]
    }
  }
};
