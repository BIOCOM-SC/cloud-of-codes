EXEC = bubble-model

CC = mpicc
FLAGS = -Iinclude -Wall -Wextra -Wpedantic -Werror -O3

DIR_OMP = /opt/homebrew/Cellar/libomp/20.1.1/include/
LIB_OMP = /opt/homebrew/Cellar/libomp/20.1.1/lib/
OMP =  -isystem $(DIR_OMP) -L$(LIB_OMP) -lomp -Xpreprocessor -fopenmp

C_FILES = $(wildcard src/*.c)

make: mb

mb: $(C_FILES)
	$(CC) $(OMP) $(FLAGS) -o $(EXEC) $(C_FILES)

debug: $(C_FILES)
	$(CC) $(OMP) -Wall -Wextra -Wpedantic -Werror -g -o $(EXEC) $(C_FILES)

mn: $(C_FILES)
	mpiicx -qopenmp -Iinclude $(C_FILES) -o $(EXEC) -O3

mn_debug: $(C_FILES)
	mpiicx -qopenmp -Iinclude $(C_FILES) -o $(EXEC) -g -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls


clean:
	rm bubble
