import Web3 from "web3";
import starNotaryArtifact from "../../build/contracts/StarNotary.json";

const App = {
  web3: null,
  account: null,
  meta: null,

  start: async function() {
    const { web3 } = this;

    try {
      // get contract instance
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = starNotaryArtifact.networks[networkId];
      this.meta = new web3.eth.Contract(
        starNotaryArtifact.abi,
        deployedNetwork.address,
      );

      // get accounts
      const accounts = await web3.eth.getAccounts();

      this.account = accounts[0];
    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }
  },

  setStatus: function(message,id) {
    const status = document.getElementById(id);
    status.innerHTML = message;
  },

  createStar: async function() {
    const { createStar } = this.meta.methods;
    const name = document.getElementById("starName").value;
    const symbol = document.getElementById("starSymbol").value;
    const id = document.getElementById("starId").value;
    const result = await createStar(name,symbol, id).send({from: this.account});
    console.log(result)
    App.setStatus("New Star Owner is " + this.account + ".","status");
  },

  // Implement Task 4 Modify the front end of the DAPP
  lookUp: async function (){
    const { lookUptokenIdToStarInfo } = this.meta.methods;
    const lookId = document.getElementById("lookid").value;
    let starInfo = await lookUptokenIdToStarInfo(lookId).call();
    const {0: name, 1: symbol} = starInfo;
    App.setStatus("Star info: Name:" + name+" Symbol:" + symbol, "status");
  },

  getOwner: async function (){
    const { getOwnerStar } = this.meta.methods;
    const lookId = document.getElementById("tokenid").value;
    let starInfo = await getOwnerStar(lookId).call();
    App.setStatus("Star owner:" + starInfo, "owner");
  },

  exchange: async function (){
    const { exchangeStars } = this.meta.methods;
    const lookId1 = document.getElementById("lookid1").value;
    const lookId2 = document.getElementById("lookid2").value;
    await exchangeStars(lookId1,lookId2).send({from: this.account});
    App.setStatus("Exchange done", "message");
  },

  transfer: async function (){
    const { transferStar } = this.meta.methods;
    const addressTO = document.getElementById("addressto").value;
    console.log(addressTO)
    const tokenId = document.getElementById("tokenidto").value;
    await transferStar(addressTO,tokenId).send({from: this.account});
    App.setStatus("Transfer done", "messagetransfer");
  }

};

window.App = App;

window.addEventListener("load", async function() {
  if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum);
    await window.ethereum.request({ method: "eth_requestAccounts" }); // get permission to access accounts
  } else {
    console.warn("No web3 detected. Falling back to http://127.0.0.1:9545. You should remove this fallback when you deploy live",);
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:9545"),);
  }

  App.start();
});