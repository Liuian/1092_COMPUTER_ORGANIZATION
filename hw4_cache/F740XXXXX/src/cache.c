//21:35 06.03.2021
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
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
//check hit or miss
int judge_hit(int cache[][2], int index, int tag){
	if(cache[index][1] == tag){//hit
		return 1;
	}
	else{//miss
		return 0;
	}
}
//put tag into cache
void update_tag(int cache[][2], int index, int tag){
	cache[index][1] = tag;
}
/*
//write into file
void write(file_out, output){
	fprintf(file_out, "%d", output);
}
*/
//main
int main(int argc, char **argv){
	int cache_size, block_size, associativity, replace;
	int cache_set, index_length, offset_length, tag_length;//#index, #offset, #tag
	char hex_string_addr[15];
	//open file
	FILE *file_in, *file_out;
	file_in = fopen(argv[1], "r");
	file_out = fopen(argv[2], "w");
	//set variable
	fscanf(file_in, "%d%d%d%d", &cache_size, &block_size, &associativity, &replace);
	cache_set = cache_size * 1000 / block_size;
	index_length = ceil(log2(cache_set));
	offset_length = log2(block_size);
	tag_length = 32 - index_length - offset_length;
	//build cache & initial cache
	int cache[cache_set][2];//cache[index][1] = valid(0 or 1); cache[index][2] = tag;
	for(int i = 0; i < cache_set; i++){
		for(int j = 0; j < 2; j++){
			cache[i][j] = 0;
		}
	}
	//loop to read the addresses & compare
	while(fscanf(file_in, "%s", hex_string_addr) != EOF){
		//hex to dec
		long int dec_string_addr = trans_hex_to_dec(hex_string_addr);		//printf("%ld", dec_string_addr);
		//calculate tag
		int tag  = get_tag(dec_string_addr, index_length, offset_length);		//printf("%d\n", tag);
		//calculate index
		int index = get_index(dec_string_addr, index_length, offset_length);
		//check valid, then check hit or miss, do whole process
		if(cache[index][0] == 0){//valid = 0
			//put tag & into cache
			update_tag(cache, index, tag);
			cache[index][0] = 1;
			//return -1
			fprintf(file_out, "%d\n", -1);
		}
		else{//valid = 1
			//check hit or miss
			if(judge_hit(cache, index, tag) == 1){//hit
				//return -1
				fprintf(file_out, "%d\n", -1);
			}
			else{//miss
				//return current tag
				fprintf(file_out, "%d\n", cache[index][1]);
				//put tag into cache
				update_tag(cache, index, tag);
			}
		}
	}
	
	//fprintf(file_out, "%f\n%f\n%f\n%f", cache_set, index_length, offset_length, tag_length);
	fclose(file_in);
	fclose(file_out);
	return 0;
}
