pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC721{
    event Transfer(address indexed from,address indexed to,uint indexed tokenId);
    event Approval(address indexed owner,address indexed approved,uint indexed tokenId);
    event ApprovalForAll(address indexed owner,address indexed operator,bool approved);
    function balanceOf(address)external view returns(uint);
    function ownerOf(uint)external view returns(address);
    function safeTransferFrom(address,address,uint)external;
    function transferFrom(address,address,uint)external;
    function approve(address,uint)external;
    function getApproved(uint)external view returns(address);
    function setApprovalForAll(address,bool)external;
    function isApprovedForAll(address,address)external view returns(bool);
    function safeTransferFrom(address,address,uint,bytes calldata)external;
}
interface IERC721Metadata{
    function name()external view returns(string memory);
    function symbol()external view returns(string memory);
    function tokenURI(uint)external view returns(string memory);
}
contract ERC721AC is IERC721,IERC721Metadata{
    address internal _owner;
    string private _name;
    string private _sym;
    mapping(uint=>address)internal _owners;
    mapping(address=>uint)internal _balances;
    mapping(uint=>address)internal _tokenApprovals;
    mapping(address=>mapping(address=>bool))internal _operatorApprovals;
    constructor(string memory name_,string memory sym_){
        (_owner,_name,_sym)=(msg.sender,name_,sym_);
    }
    function supportsInterface(bytes4 a)external pure returns(bool){
        return a==type(IERC721).interfaceId||a==type(IERC721Metadata).interfaceId;
    }
    function balanceOf(address a)external view override virtual returns(uint){
        return _balances[a];
    }
    function ownerOf(uint a)public view override virtual returns(address){
        return _owners[a]; 
    }
    function owner()external view returns(address){
        return _owner;
    }
    function name()external override view returns(string memory){
        return _name;
    }
    function symbol()external override view returns(string memory){
        return _sym;
    }
    function tokenURI(uint)external view override virtual returns(string memory){
        return"";
    }
    function approve(address a,uint b)external override{
        require(msg.sender==ownerOf(b)||isApprovedForAll(ownerOf(b),msg.sender));
        _tokenApprovals[b]=a;
        emit Approval(ownerOf(b),a,b);
    }
    function getApproved(uint a)public view override returns(address){
        return _tokenApprovals[a];
    }
    function setApprovalForAll(address a,bool b)external override{
        _operatorApprovals[msg.sender][a]=b;
        emit ApprovalForAll(msg.sender,a,b);
    }
    function isApprovedForAll(address a,address b)public view override returns(bool){
        return _operatorApprovals[a][b];
    }
    function transferFrom(address a,address b,uint c)public virtual override{unchecked{
        require(a==ownerOf(c)||getApproved(c)==a||isApprovedForAll(ownerOf(c),a));
        (_tokenApprovals[c]=address(0),_balances[a]-=1,_balances[b]+=1,_owners[c]=b);
        emit Approval(ownerOf(c),b,c);
        emit Transfer(a,b,c);
    }}
    function safeTransferFrom(address a,address b,uint c)external override{
        transferFrom(a,b,c);
    }
    function safeTransferFrom(address a,address b,uint c,bytes memory)external override{
        transferFrom(a,b,c);
    }
}
