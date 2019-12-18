#include <stdio.h>
#include <stdint.h>

int main(int argc, char **argv)
{
	if (argc != 2) return 1;
	int depth;
	sscanf(argv[1], "%d", &depth);
	printf("DEPTH\t\t=\t%d;\n", depth);
	printf("WIDTH\t\t=\t8;\n");
	printf("ADDRESS_RADIX\t=\tHEX;\n");
	printf("DATA_RADIX\t=\tHEX;\n");
	printf("CONTENT\t BEGIN\n");
	uint8_t content;
	size_t index = 0;
	while (fread(&content, 1, sizeof(uint8_t), stdin) == sizeof(uint8_t)) {
		printf("%x\t\t:%02x;\n", (unsigned int) index, (unsigned int)content);
		index++;
	}
	if (index == depth - 1)
		printf("%x\t\t:%02x;\n", (unsigned int) (depth - 1), (unsigned int) 0);
	else if (index < depth - 1)
		printf("[%x..%x]\t:%02x;\n", (unsigned int) index, (unsigned int) (depth - 1), (unsigned int) 0);
	printf("END;\n");
}
