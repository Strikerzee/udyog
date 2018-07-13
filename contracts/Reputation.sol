pragma solidity ^0.4.20;

contract Reputation{

    struct Profile{
        uint8 send;
        uint8 recommend;
        bytes32[] reqs;
        bytes32[] recs;
    }

    uint public num;    
    mapping(bytes32=>uint) _repo;
    mapping(bytes32=>Profile) status;
    mapping(bytes32=>string) _names;
    bytes32[] enrolled;
    mapping(uint=>mapping(bytes32=>uint)) skillScore;
    mapping(string=>uint) skillNames;
    uint skillCtr;
    
    event Requested(bytes32 indexed _id, string _name, string skill);
    event Recommended(bytes32 indexed _id, string _name);
    event Received(bytes32 indexed _id, string _from, bytes32 _fromId);
    event attested(bytes32 indexed _toId, bytes32 indexed _fromId);
    
    function requestRecommendation(bytes32 _from, bytes32 _to,string skill) public returns(bool){
        require(_from!=bytes32(0) && _to!=bytes32(0) && _from!=_to);
        //adding to request queue of recommender
        uint no;
        if(skillNames[skill]==0 && skillCtr==0){
            skillNames[skill]=skillCtr;
             no=skillCtr;
            skillCtr+=1;
        }
        else{
           no=skillNames[skill]; 
        }
        bytes32[] _reqs=status[_to].reqs;
        _reqs.push(_from);
        status[_to].reqs=_reqs;
        status[_from].send-=1;
        emit Requested(_from, _names[_from],skill);
        return true;
    }
    
    function recommend(bytes32 _to,bytes32 _from, uint _percentage,string skill){
        //requires
        bytes32[] _reqs=status[_from].reqs;
        bytes32[] _recs=status[_to].recs;
        if(_reqs.length==1 && _reqs[0] == _to){
          delete _reqs[_reqs.length-1];
         _reqs.length--;}
        else{
           uint index; uint j; bool check;
           for( j=0;j<=_reqs.length-1;j++){
              if(_reqs[j] == _to){
                  index=j;
                  check=true;
                  break;
          }}
          if(check){
            for ( j = index; j<_reqs.length-1; j++){
                _reqs[j] = _reqs[j+1];
            }
            delete _reqs[_reqs.length-1];
            _reqs.length--;
            
        }
        else{
            revert();
        }
        
       }
       status[_from].reqs=_reqs;
       
       uint update=_repo[_from]*_percentage;
       update=update/100;
       uint no=skillNames[skill];
       skillScore[no][_to]+=update;
       _repo[_to]+=update;
       
       _repo[_from]+=_repo[_to]/100;
       
       bytes32[] rec=status[_to].recs;
       rec.push(_from);
       status[_to].recs=rec;
       
    
       status[_from].recommend-=1;
        
       //events
       emit Recommended(_from, _names[_to]);
       emit Received(_to, _names[_from], _from);
    
      
    }
    
    function getRepo(bytes32 _id) view returns (uint){
        return _repo[_id];
    }
    
    
    function register(string name,uint repo,bytes32 _id) public{
        require(repo!=0 && _id!=bytes32(0));
        _repo[_id]=repo;
        
         enrolled.push(_id);
         _names[_id]=name;
           
    }
    
    function refilTokens() public{
        for(uint i=0;i<enrolled.length;i++){
            Profile p=status[enrolled[i]];
            p.send=5;
            p.recommend=5;
        }
    }
    
    function addNum(uint s) public {
        num = s;
    }
    function addUniv(bytes32 _id) public{
        _repo[_id]=50;
    }
    
    function updateRepo(bytes32 _id,uint repo) public{
        //requires
        _repo[_id]=_repo[_id]+repo;
    }
    
    function getName(bytes32 _id) view public returns(string){
        return _names[_id];
    }
    /*
    function addSkill(string name) public{
        skillNames[name]=skillCtr;
        skillCtr+=1;
        
    }*/
    
    //skill to request
    
    function attest(bytes32 _to, bytes32 _from) public{
        uint repo_user=_repo[_to];
        uint repo_univ=_repo[_from];
        uint update1=repo_user*3;
        update1=update1/100;
        uint update2=repo_univ*10;
        update2=update2/100;
        _repo[_to]+=update2;
        _repo[_from]+=update1;
        emit attested(_to,_from);
        
    }
    
    function getRequests(bytes32 id) public view returns(bytes32[]){
        return status[id].reqs;
    }
    
     function getRecs(bytes32 id) public view returns(bytes32[]){
        return status[id].recs;
    }
    
    
    
}
