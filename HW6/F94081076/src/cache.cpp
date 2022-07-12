#include<string.h>
#include<iostream>
#include<fstream>
#include<vector>
#include<math.h>
#include<bitset>
#include<algorithm>
#include<iomanip>
#define FIFO 0 
#define LRU 1
#define DIRECT_MAPPED 0
#define FOUR_WAY_SET 1
#define FULLY_ASSOC 2
#define NotHit_But_Available -2
#define NotHit -1
#define Hit -3

using namespace std;


class Cache{
    
    public: 
        int Cache_size, Block_size, Associativity, ReplaceType, NumEntries;
        int Tag_width, Offset_width, CacheIdx_width;
        int Row,Col;
        int NumSet;
        double miss_Num, try_Num;
        vector<vector<pair<bool,unsigned>>> cacheVec;
        Cache(int, int ,int ,int);
        int Process(unsigned);
        unsigned  getTag(unsigned , int);
        unsigned getIndex(unsigned , int, int);
        int processHit(unsigned, unsigned);
        void LRU_Util(vector<pair<bool, unsigned>>& ,unsigned, unsigned, int);
        unsigned LRU_Util(vector<pair<bool, unsigned>>& ,unsigned, unsigned);
        unsigned FIFO_Util(vector<pair<bool, unsigned>>&,unsigned);

};

Cache::Cache(int Cache_size, int Block_size
                ,int Associativity,int ReplaceType){
    this->Associativity=Associativity;
    this->Block_size=Block_size;
    this->Cache_size=Cache_size;
    this->ReplaceType=ReplaceType;
    miss_Num=0;
    try_Num=0;
    this->NumEntries=(int)(Cache_size/Block_size); //blocks number
    // cout<<"blocks number "<<NumEntries<<endl;
    this->Offset_width = log2(Block_size*4);
    // cout<<"offset width "<<Offset_width<<endl;
    if(Associativity==DIRECT_MAPPED){
        this->Row=NumEntries;
        this->Col=1;
        this->CacheIdx_width = log2(NumEntries);
        
    }else if(Associativity==FOUR_WAY_SET){
        this->Row=NumEntries/4;
        this->Col=4;
        this->CacheIdx_width = log2(NumEntries/4);    //set index width
    }else if(Associativity==FULLY_ASSOC){
        this->Row=1;
        this->Col=NumEntries;
        this->CacheIdx_width=0; //only one row,so index is not necessary
    }
    // cout<<"cacheIdx_width "<<CacheIdx_width<<endl;
    this->Tag_width = 32-CacheIdx_width-Offset_width;
    // cout<<"Tag_width "<<Tag_width<<endl;
    // cout<<"cache Row: "<<this->Row<<endl;
    // cout<<"cache Col: "<<this->Col<<endl;
    cacheVec.resize(this->Row);
    for(int i=0;i<this->Row;i++){
        cacheVec[i].resize(Col);
        for(int j=0;j<Col;j++){
            cacheVec[i][j].first=false;
            cacheVec[i][j].second=0;
        }
    }
}

unsigned Cache::getIndex(unsigned word_addr, int Tag_width, int offset_width){
    unsigned idx=0; //0x0
    bitset<32> bi(word_addr);
    for(int i = 31-Tag_width; i>=offset_width; i--){
        idx = idx<<1;
        idx = idx | bi[i];
    }
    bitset<32> bidx(idx);

    if(Associativity==FOUR_WAY_SET){
        idx=idx%this->Row;
    }else if(Associativity==FULLY_ASSOC){
        idx=0;
    }
    return idx;
}

unsigned Cache::getTag(unsigned  word_addr, int Tag_width){
    unsigned tag=0; //0x0
    bitset<32> bi(word_addr);
    for(int i=31 ; i>(31-Tag_width);i--){
        tag = tag<<1;
        tag = tag | bi[i];
    }
    return tag;
}

unsigned Cache::FIFO_Util(vector<pair<bool, unsigned>> &Row_cache,unsigned tag){
    unsigned victim=(*Row_cache.begin()).second;
    Row_cache.erase(Row_cache.begin());
    Row_cache.push_back(pair<bool, unsigned>(true, tag));
    return victim;
}

unsigned Cache::LRU_Util(vector<pair<bool, unsigned>> &Row_cache,unsigned tag, unsigned index){
    unsigned victim=(*Row_cache.begin()).second;
    Row_cache.erase(Row_cache.begin());
    Row_cache.push_back(pair<bool, unsigned>(true, tag));
    return victim;
}
//overloading
void Cache::LRU_Util(vector<pair<bool, unsigned>> &Row_cache,unsigned tag, unsigned index, int pos_inVec){
    pair<bool, unsigned>tmp = Row_cache[pos_inVec];
    int idx=pos_inVec;
    while(Row_cache[idx+1].first==true){  
        Row_cache[idx]=Row_cache[idx+1];
        Row_cache[idx+1]=tmp;
        idx++;
        if(idx>=this->Col) break;
    }

}


int Cache::processHit(unsigned tag, unsigned index){
    bool available=false;
    for(int i=0; i<Col; i++){
        // cout<<"cacheVec[index][i].second="<<cacheVec[index][i].second<<endl;
        if(cacheVec[index][i].first==false){ //empty
            cacheVec[index][i].second=tag;
            cacheVec[index][i].first=true;
            available=true;
            miss_Num++;
            return NotHit_But_Available;
        }else{
            if(cacheVec[index][i].second==tag){ //hit
                if(ReplaceType==LRU){ //update the order
                    LRU_Util(cacheVec[index], tag, index, i);
                }
                return Hit;
            }else{
                continue;
            }
        }
    }
    if(available==false){ //not hit and also has no empty cache
        miss_Num++;
        return NotHit;
    }
    return -1;
}

int Cache::Process(unsigned word_addr){
    unsigned tag = getTag(word_addr, this->Tag_width);
    unsigned index = getIndex(word_addr, this->Tag_width, this->Offset_width);
    // cout<<"get tag: "<<tag<<endl;
    // cout<<"get index "<<index<<endl;
    try_Num++;
    int hitResult=processHit(tag, index);
    // cout<<"hit result: "<<hitResult<<endl;
    unsigned victim;
    if(hitResult==NotHit){
        if(ReplaceType==FIFO){
            victim=FIFO_Util(cacheVec[index], tag);
        }else if(ReplaceType==LRU){
            victim=LRU_Util(cacheVec[index], tag, index);
        }
    }else if(hitResult==NotHit_But_Available){
        return -1;
    }else if(hitResult==Hit){ //hit and return index of postion
        return -1;
    }
    // cout<<"victim is "<<victim<<endl;
    return victim;
    
}

int main(int argc, char** argv){
    int Cache_size, Block_size, Associativity, ReplaceType;
    unsigned Word_addr;
    ifstream fin;
    ofstream fout;
    fin.open(argv[1]);
    fout.open(argv[2]);
    Cache *cache;
    if(fin.is_open() && fout.is_open()){
        fin>>Cache_size>>Block_size
                >>Associativity>>ReplaceType;
        cache = new Cache(Cache_size,Block_size,Associativity,ReplaceType);
        while(fin>>Word_addr){
            Word_addr*=4;
            // cout<<"Word_addr(bytes): "<<Word_addr<<endl;
            fout<<cache->Process(Word_addr)<<endl;
        }
        cout << "Miss rate = " <<fixed<<setprecision(6) << cache->miss_Num/cache->try_Num;
        fout << "Miss rate = " <<fixed<<setprecision(6) << cache->miss_Num/cache->try_Num;  
    }
    fin.close();
    fout.close();
    return 0;
}