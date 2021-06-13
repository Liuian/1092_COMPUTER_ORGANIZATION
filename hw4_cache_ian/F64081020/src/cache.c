//18:37 06.04.2021
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <strings.h>
#include <time.h>
//int cache_set_length = 0;
//int cache_set = 0;
//hex to dec
long int trans_hex_to_dec(char hex_string_addr[]){
	long int dec_string_addr; 
	dec_string_addr = strtol(hex_string_addr, NULL, 0); //printf ("%s, %ld\n", hex, addr);
	return dec_string_addr;
}
//find tag in dec
int get_tag(long int dec_string_addr, int index_length, int offset_length){
	int tag;
	tag = dec_string_addr / pow(2, index_length + offset_length);	//printf("%d %d ", index_length, offset_length); 	//printf("%ld, %f\n", dec_string_addr, pow(2, index_length + offset_length));
	return tag;
}
//find the index in dec
int get_index(long int dec_string_addr, int index_length, int offset_length){
	int index;
	index = dec_string_addr / pow(2, offset_length);	//printf("%d, ", index);
	index = index % (int)pow(2, index_length);	//printf("%d\n", index);
	return index;
}
//build cache
//build cache - initial cache
void initial_cache(int cache_set, int cache_set_length, int cache[cache_set][cache_set_length]){
	//printf("%d, %d", cache_set, cache_set_length);
	for(int i = 0; i < cache_set; i++){
		for(int j = 0; j < cache_set_length; j++){
			cache[i][j] = 0;
		}
	}
}
//check hit or miss
int judge_hit(int index, int tag, int cache_set_length, int cache[][cache_set_length]){
	for(int i = 1; i < cache_set_length; i++){//cache[][0] = valid, skip
		//printf("in_judge_hit: cache = %d, tag = %d, i = %d, index = %d\n", cache[index][1], tag, i, index);
		if(cache[index][i] == tag){//hit
			//printf("==");
			return 1;
		}
	}
	return 0;//miss
}
//------------main-------------
int main(int argc, char **argv){
	int cache_size, block_size, associativity, replace;
	int cache_block, cache_set, index_length, offset_length, tag_length, cache_set_length;//#index, #offset, #tag
	char hex_string_addr[15];
	/***********************************
	*************open file**************
	***********************************/
	FILE *file_in, *file_out;
	file_in = fopen(argv[1], "r");
	file_out = fopen(argv[2], "w");
	/***********************************
	**********setup variable************
	***********************************/
	fscanf(file_in, "%d%d%d%d", &cache_size, &block_size, &associativity, &replace);
	cache_block = cache_size * 1024 / block_size;
	//cache_set & cache_set_length
	if(associativity == 0){//direct-mapped
		cache_set = cache_block;
		cache_set_length = 2;//#1 valid + #1 tag
	}
	else if(associativity == 1){//4_way
		cache_set = cache_block / 4;
		cache_set_length = 5;//#1 valid + #4 tag
	}
	else{//fully
		cache_set = 1;
		cache_set_length = 1 + cache_block;//#1 valid + #cache_block tag
	}	//printf("%d", cache_block);
	index_length = ceil(log2(cache_set));	//printf("%d\n", index_length);
	offset_length = log2(block_size);
	tag_length = 32 - index_length - offset_length;
	/**********************************
	 ****build cache & initial cache***
	 *********************************/
	int cache[cache_set][cache_set_length];//cache[index][0] = valid(0 or 1); cache[index][others] = tag;
	initial_cache(cache_set, cache_set_length, cache);
	/*********************************
	 ************start****************
	 ********************************/
	//loop to read the addresses & compare
	while(fscanf(file_in, "%s", hex_string_addr) != EOF){
		//hex to dec
		long int dec_string_addr = trans_hex_to_dec(hex_string_addr);		//printf("%ld", dec_string_addr);
		//calculate tag
		int tag  = get_tag(dec_string_addr, index_length, offset_length);		
		//calculate index
		int index = get_index(dec_string_addr, index_length, offset_length);
		//check valid, then check hit or miss, do whole process
		if(cache[index][0] == 0){//valid = 0
			//put tag & into cache
			cache[index][1] = tag;			//update_tag(cache, index, tag);			//printf("valid = 0, %d\n", cache[index][1]);
			//set valid = 1
			cache[index][0] = 1;
			//return -1
			fprintf(file_out, "%d\n", -1);			//fprintf(file_out, "%d", -1);
		}
		else{//valid = 1
			//check hit or miss
			//judge_hit------------不知道為什麼放進函式cache[][1]就會變0--------------
			int machs_tag_num;
			int test = 0;
			for(machs_tag_num = 1; machs_tag_num < cache_set_length; machs_tag_num++){//cache[][0] = valid, skip
				if(cache[index][machs_tag_num] == tag){//hit
					test = 1;
					break;
					//return 1;
				}
			}
			//第幾個位置mach
			//printf("%d", machs_tag_num);
			//-----------------------不知道為什麼放進函式cache[][1]就會變0-----------
			if(test == 1){//hit
			//if(judge_hit(index, tag, cache_set_length, cache) == 1){//hit
				//if(replace == 0)/*FIFO & HIT*/{NO NEED TO DO ANYTHING}
				//if(replace == 1) {change the sequence - LRU need}
				if(replace == 1){//LRU 把該tag移到最後一個
					int i;
					if(cache[index][cache_set_length - 1] != 0){//hit & full
						for(i = machs_tag_num; i < cache_set_length - 1; i++){
							cache[index][i] = cache[index][i + 1];
						}
						cache[index][cache_set_length - 1] = tag;
					}
					else{//hit & NOT full
						for(i = machs_tag_num; i < cache_set_length - 1; i++){
							cache[index][i] = cache[index][i + 1];
							if(cache[index][i] == 0){
								cache[index][i] = tag;
								break;
							}
						}
					}
				}
/*				else if(replace == 2){//your policy(先當成LRU試試看)
					int i;
					if(cache[index][cache_set_length - 1] != 0){//hit & full
						for(i = machs_tag_num; i < cache_set_length - 1; i++){
							cache[index][i] = cache[index][i + 1];
						}
						cache[index][cache_set_length - 1] = tag;
					}
					else{//hit & NOT full
						for(i = machs_tag_num; i < cache_set_length - 1; i++){
							cache[index][i] = cache[index][i + 1];
							if(cache[index][i] == 0){
								cache[index][i] = tag;
								break;
							}
						}
					}
				}
*/				//return -1
				fprintf(file_out, "%d\n", -1);//fprintf(file_out, "%d", -1);
			}	
			else{//miss
				if(cache[index][cache_set_length - 1] == 0){//miss & NOT full, no need to kick tag
					for(int i = 1; i < cache_set_length; i++){
						if(cache[index][i] == 0){
							cache[index][i] = tag;
							break;
						}
					}
					fprintf(file_out, "%d\n", -1);
					//fprintf(file_out, "%d", -1);
				}
				else{//miss & full, need to kick one tag
					if(replace == 2){
						srand( time(NULL) );
						int x = rand();
						x = (x % cache_set_length - 1) + 1;
						fprintf(file_out, "%d\n", cache[index][x]);
						cache[index][x] = tag;
					}
					else{
						//for FIFO or LRU kick first value, return kicked tag
						fprintf(file_out, "%d\n", cache[index][1]);
						//fprintf(file_out, "%d", cache[index][1]);
						//change the sequence, 全部往前移一格
						for(int i = 1; i < cache_set_length - 1; i++){
							cache[index][i] = cache[index][i + 1];
						}
						//put new tag into cache(in last place)
						//update_tag(cache, index, tag);
						cache[index][cache_set_length - 1] = tag;
					}
				}
			}
		}
		//----------print array---------------
		//fprintf(file_out, "tag : %d. index : %d. ", tag, index);
		//for(int i = 0; i < cache_set_length; i++){
		//	fprintf(file_out, "%d, ", cache[index][i]);
		//}
		//fprintf(file_out, "\n");
		//------------------------------
	}
	
	//fprintf(file_out, "%f\n%f\n%f\n%f", cache_set, index_length, offset_length, tag_length);
	fclose(file_in);
	fclose(file_out);
	return 0;
}
