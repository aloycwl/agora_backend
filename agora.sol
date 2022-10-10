pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC721{
    function ownerOf(uint256)external view returns(address);
    function getApproved(uint256)external view returns(address);
    function transferFrom(address,address,uint256)external;
    function tokenURI(uint256)external view returns(string memory);
}
contract agora{
    struct List{
        address contractAddr;
        uint tokenId;
        uint price;
    }    
    uint public Listed;
    uint public Sold;
    address private _owner;
    mapping(uint=>List)public list;
    constructor(){
        _owner=msg.sender;
    }
    function Sell(address _contractAddr,uint _tokenId,uint _price)external{unchecked{
        /*  Listing the nft into our marketplace.
            Using Listed to keep track of the number of nfts
            Only approved and owner    */
        require(IERC721(_contractAddr).getApproved(_tokenId)==address(this));
        require(IERC721(_contractAddr).ownerOf(_tokenId)==msg.sender);
        List storage l=list[Listed];
        (l.contractAddr,l.tokenId,l.price)=(_contractAddr,_tokenId,_price);
        Listed++;
    }}
    function Buy(uint _id)external payable{unchecked{
        /*  As long as the price is right, this transaction will go through
            Have to transfer to contract first before executing another transfer out
            Pay previous owner and 1% to admin  */
        (uint _tokenId,uint _price)=(list[_id].tokenId,list[_id].price);
        require(msg.value>=_price);
        address _ca=list[_id].contractAddr;
        address _previousOwner=IERC721(_ca).ownerOf(_tokenId);
        IERC721(_ca).transferFrom(_previousOwner,address(this),_tokenId);
        IERC721(_ca).transferFrom(address(this),msg.sender,_tokenId);
        payable(_previousOwner).transfer(_price*99);
        (Sold++,Listed--);
        delete list[_id];
    }}
    function Show(uint batch, uint offset)external view returns
        (string[]memory tu,uint[]memory price,uint[]memory listId){unchecked{
        /*  Only show the batch number of nfts e.g. 20 per page to prevent overloading
            Usng while loop to get the batch number and break at 0
            Skip listing that no longer have allowance to us    */
        (tu,price,listId) = (new string[](batch),new uint[](batch),new uint[](batch));
        uint b;
        uint i=Listed-offset;
        while (b<batch&&i>0){
            uint j=i-1;
            if(IERC721(list[j].contractAddr).getApproved(list[j].tokenId)==address(this)){
                (tu[b],price[b],listId[b])=
                (IERC721(list[j].contractAddr).tokenURI(list[j].tokenId),list[j].price,i);
                b++;
            }
            i--;
        }
    }}
    function Withdraw()external{
        require(msg.sender==_owner);
        payable(msg.sender).transfer(address(this).balance);
    }
}