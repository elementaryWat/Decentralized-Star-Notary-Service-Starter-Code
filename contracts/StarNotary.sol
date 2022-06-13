pragma solidity >=0.7.0 <0.9.0;

//Importing openzeppelin-solidity ERC-721 implemented Standard
import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

// StarNotary Contract declaration inheritance the ERC721 openzeppelin implementation
contract StarNotary is ERC721 {

    // Star data
    struct Star {
        string name;
        string symbol;
    }

    constructor(string memory name, string memory symbol) ERC721(name,symbol){
    }
    

    // mapping the Star with the Owner Address
    mapping(uint256 => Star) public tokenIdToStarInfo;
    // mapping the TokenId and price
    mapping(uint256 => uint256) public starsForSale;

    
    // Create Star using the Struct
    function createStar(string memory _name, string memory _symbol,uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name,_symbol); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        _safeTransfer(ownerAddress, msg.sender, _tokenId, ""); // We can't use _addTokenTo or_removeTokenFrom functions, now we have to use _transferFrom
        address payable ownerAddressPayable = payable(ownerAddress); // We need to make this conversion to be able to use transfer() function to transfer ethers
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            payable(msg.sender).transfer(msg.value - starCost);
        }
    }

    function lookUptokenIdToStarInfo (uint _tokenId) public view returns (string memory name, string memory symbol) {
        name=tokenIdToStarInfo[_tokenId].name;
        symbol=tokenIdToStarInfo[_tokenId].symbol;
    }

    function getOwnerStar (uint _tokenId) public view returns (address) {
        return ownerOf(_tokenId);
    }

    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        require(ownerOf(_tokenId1) == msg.sender || ownerOf(_tokenId2) == msg.sender, "You can't perform the exchange transaction because you don't own any of the stars");
        address tempOwnerT1 = ownerOf(_tokenId1);
        _safeTransfer(ownerOf(_tokenId1), ownerOf(_tokenId2), _tokenId1,"");
        _safeTransfer(ownerOf(_tokenId2), tempOwnerT1, _tokenId2,"");
    }

    function transferStar(address _to, uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't perform the exchange transaction because you don't own the star");
        _safeTransfer(msg.sender, _to, _tokenId,"");
    }

}
