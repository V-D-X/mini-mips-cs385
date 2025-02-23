FROM ubuntu:latest

RUN apt update && apt install -y \
    iverilog \
    verilator \
    gtkwave

WORKDIR /workspace
ENTRYPOINT ["/bin/bash"]