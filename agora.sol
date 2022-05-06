pragma solidity>0.8.0;//SPDX-License-Identifier:None
//interface erc20 + eth contract address for purchase
/*
Only getting the essentials
*/
interface IERC721{
    function ownerOf(uint256 tokenId)external view returns(address owner);
    function getApproved(uint256 tokenId)external view returns(address operator);
    function transferFrom(address from,address to,uint256 tokenId)external;
    function tokenURI(uint256 tokenId)external view returns(string memory);
}
contract agora{
    //list nfts function
        //to list the latest one first
    //input function
    //create allowance function
    //clean up periodically (if getApproved no longer is us=remove + sold)
    struct List{
        address contractAddr;
        uint tokenId;
        uint price;
    }
    mapping(uint=>List)public list;
    address private _admin;
    uint public Listed;
    uint public Sold;
    constructor(){
        _admin=msg.sender;
    }
    /*  Listing the nft into our marketplace.
        Using Listed to keep track of the number of nfts
        Will be deleting sold tokens  */
    function Sell(address _contractAddr,uint _tokenId,uint _price)external{unchecked{
        require(IERC721(_contractAddr).getApproved(_tokenId)==address(this)); //Contract authorised to sell
        require(IERC721(_contractAddr).ownerOf(_tokenId)==msg.sender); //Owner is selling
        (list[Listed].contractAddr,list[Listed].price)=(_contractAddr,_price);
        Listed++;
    }}
    /*  As long as the price is right, this transaction will go through
        Have to transfer to contract first before executing another transfer out
        Pay previous owner and 1% to admin
    */
    function Buy(uint _id)external payable{unchecked{
        (uint _tokenId,uint _price)=(list[_id].tokenId,list[_id].price);
        require(msg.value>=_price);
        address _ca=list[_id].contractAddr;
        address _previousOwner=IERC721(_ca).ownerOf(_tokenId);
        IERC721(_ca).transferFrom(_previousOwner,address(this),_tokenId);
        IERC721(_ca).transferFrom(address(this),msg.sender,_tokenId);
        (bool s,)=payable(payable(_previousOwner)).call{value:_price*99/100}("");
        (s,)=payable(payable(_admin)).call{value:_price*99/100}("");
        Sold++;
        delete list[_id];
    }}
    
    function Show(uint batch)external{
        
    }
}