pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC721{
    function ownerOf(uint256)external view returns(address);
    function getApproved(uint256)external view returns(address);
    function transferFrom(address,address,uint256)external;
    function tokenURI(uint256)external view returns(string memory);
}
contract agora{
    struct List{
        address nftAdd;
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
    function Sell(address _nftAdd,uint _tokenId,uint _price)external{unchecked{
        /*  Listing the nft into our marketplace.
            Using Listed to keep track of the number of nfts
            Only approved and owner    */
        require(IERC721(_nftAdd).getApproved(_tokenId)==address(this));
        require(IERC721(_nftAdd).ownerOf(_tokenId)==msg.sender);
        List storage l=list[Listed];
        (l.nftAdd,l.tokenId,l.price)=(_nftAdd,_tokenId,_price);
        Listed++;
    }}
    function Buy(uint _id)external payable{unchecked{
        /*  As long as the price is right, this transaction will go through
            Have to transfer to contract first before executing another transfer out
            Pay previous owner and 1% to admin  */
        List storage l=list[_id];
        uint _price=l.price;
        require(msg.value>=_price);
        address seller=IERC721(l.nftAdd).ownerOf(l.tokenId);
        IERC721(l.nftAdd).transferFrom(seller,address(this),l.tokenId);
        IERC721(l.nftAdd).transferFrom(address(this),msg.sender,l.tokenId);
        payable(seller).transfer(_price*99);
        Sold++;
        delete list[_id];
    }}
    function Show(uint batch, uint offset)external view returns
    (string[]memory tu,uint[]memory price,uint[]memory listId){unchecked{
        /*  Only show the batch number of nfts e.g. 20 per page to prevent overloading
            Usng while loop to get the batch number and break at 0
            Skip listing that no longer have allowance to us    */
        (tu,price,listId)=(new string[](batch),new uint[](batch),new uint[](batch));
        uint b;
        uint i=Listed-offset;
        while(b<batch&&i>0){
            uint j=i-1;
            List storage l=list[j];
            if(IERC721(l.nftAdd).getApproved(l.tokenId)==address(this)){
                b++;
                (tu[b],price[b],listId[b])=(IERC721(l.nftAdd).tokenURI(l.tokenId),l.price,i);
            }
            i--;
        }
    }}
    function Withdraw()external{
        require(msg.sender==_owner);
        payable(msg.sender).transfer(address(this).balance);
    }
}