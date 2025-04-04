# compiler and flags
IVERILOG = iverilog
VVP = vvp
FLAGS = -Wall

# directories
SRC_DIR = ./src
TEST_DIR = ./test
BUILD_DIR = ./results

# ensure build directory exists before running any target
$(shell mkdir -p $(BUILD_DIR))

# finding all source files in src/
SRC_FILES = $(shell find $(SRC_DIR) -type f -name "*.v")

# finding all testbench files in test/
TESTBENCH_FILES = $(shell find $(TEST_DIR) -type f -name "*.v")

# concatenated source file
ALL_SRC = $(BUILD_DIR)/all_sources.v

# default targets
all: concatenate compile simulate

concatenate: $(SRC_FILES) $(TESTBENCH_FILES)	
	@echo
	@echo "Concatenating all Verilog source files into one..."
	{ for file in $(SRC_FILES) $(TESTBENCH_FILES); do cat $$file; echo -e "\n"; done; } > $(ALL_SRC)

compile: $(ALL_SRC)
	@echo
	@echo "Compiling concatenated Verilog source file..."
	$(IVERILOG) $(FLAGS) -o $(BUILD_DIR)/simulation.out $(ALL_SRC)

simulate:
	@echo
	@echo "Running simulation..."
	$(VVP) $(BUILD_DIR)/simulation.out

clean:
	rm -rf $(BUILD_DIR)/*.out $(BUILD_DIR)/*.vcd $(ALL_SRC)

# this ensures that the targets are not mistaken for files; good practice
.PHONY: all concatenate compile simulate clean
