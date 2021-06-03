//23:49 06.02.2021
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

//hex to dec
long int trans_hex_to_dec(long int* hex_string_addr){
	long int dec_string_addr; 
	dec_string_addr = strtol(&hex_string_addr, NULL, 0); //printf ("%s, %ld\n", hex, addr);
	return dec_string_addr;
}
//find tag in dec
int getTag(long int dec_string_addr, int index_length, int offset_length){
	int tag;
	tag = dec_string_addr / pow(2, index_length + offset_length);
	//printf("%d %d ", index_length, offset_length); 
	//printf("%ld, %f\n", dec_string_addr, pow(2, index_length + offset_length));
	return tag;
}

int main(int argc, char **argv){
	int cache_size, block_size, associativity, replace;
	double cache_set, index_length, offset_length, tag_length;//#index, #offset, #tag
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
	/*
	//build cache
	int cache[cache_set][2];//cache[index][1] = valid(0 or 1); cache[index][2] = tag;
	for(int i = 0; i < cache_set; i++){
		for(int j = 0; j < 2; j++){
			cache[i][j] = 0;
		}
	}
	*/
	//read the addresses & campare
	while(fscanf(file_in, "%s", hex_string_addr) != EOF){
		//hex to dec
		long int dec_string_addr = strtol(hex_string_addr, NULL, 0); //printf ("%s, %ld\n", hex, addr);
		//long int dec_string_addr = trans_hex_to_dec(&hex_string_addr);
		//printf("%ld", dec_string_addr);

		//calculate tag
		int tag  = getTag(dec_string_addr, index_length, offset_length);
		printf("%d\n", tag);
	}
	
	//fprintf(file_out, "%f\n%f\n%f\n%f", cache_set, index_length, offset_length, tag_length);
	fclose(file_in);
	fclose(file_out);
	return 0;
}








