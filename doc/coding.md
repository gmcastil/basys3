# Indent and Formatting
Port definitions for a module or its instantiations should only use one port per
line, with the columns aligned and separated by whitespace. Interfaces may group
all inputs and outputs together in single lines such as
```systemverilog
    clocking cb @(posedge clk);
        input   awready, wready, bvalid, arready, rvalid, rdata, bresp, rresp;
        output  awaddr, awvalid, wdata, wstrb, wvalid, bready, araddr, arvalid, rready;
    endclocking
```
This allows even large interface definitions to fit on a single page and
facilitates setting up things like master and slave modports.  Signal
definitions in the inter

## Generics
When ambiguious, the names of generics in the module declaration shall specify
the bus they correspond to (i.e., `AVL_` for Avalon, `AXI_` for AXI4, `REG_` for
an internal bus, etc.).  If only one bus is used in the module, it can be left
as `ADDR_WIDTH` or `DATA_WIDTH` as appropriate. The parameters used in the
module or component instantiation shall include a bus name.
# SystemVerilog
## Interfaces

