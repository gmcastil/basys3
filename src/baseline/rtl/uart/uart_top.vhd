library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.reg_pkg.all;

entity uart_top is
    generic (
        DEVICE              : string                := "7SERIES";
        CLK_FREQ            : integer               := 100000000;
        BASE_OFFSET         : unsigned(31 downto 0) := (others=>'0');
        BASE_OFFSET_MASK    : unsigned(31 downto 0) := (others=>'0');
        DEBUG_UART_AXI      : boolean               := false;
        DEBUG_UART_CORE     : boolean               := false
    );
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;

        -- AXI4-Lite register interface
        axi4l_awvalid       : in    std_logic;
        axi4l_awready       : out   std_logic;
        axi4l_awaddr        : in    std_logic_vector(31 downto 0);

        axi4l_wvalid        : in    std_logic;
        axi4l_wready        : out   std_logic;
        axi4l_wdata         : in    std_logic_vector(31 downto 0);
        axi4l_wstrb         : in    std_logic_vector(3 downto 0);

        axi4l_bvalid        : out   std_logic;
        axi4l_bready        : in    std_logic;
        axi4l_bresp         : out   std_logic_vector(1 downto 0);

        axi4l_arvalid       : in    std_logic;
        axi4l_arready       : out   std_logic;
        axi4l_araddr        : in    std_logic_vector(31 downto 0);

        axi4l_rvalid        : out   std_logic;
        axi4l_rready        : in    std_logic;
        axi4l_rdata         : out   std_logic_vector(31 downto 0);
        axi4l_rresp         : out   std_logic_vector(1 downto 0);

        -- IRQ to global interrupt controller (GIC)
        irq                 : out   std_logic;

        -- Serial input ports (should map to a pad or an IBUF / OBUF)
        rxd                 : in    std_logic;
        txd                 : out   std_logic
    );

end entity uart_top;

architecture structural of uart_top is

    constant REG_ADDR_WIDTH     : natural := 4;
    constant NUM_REGS           : natural := 16;
    constant REG_WRITE_MASK     : std_logic_vector(NUM_REGS-1 downto 0) := b"0000_0010_0000_0010";

    constant UART_CONTROL_REG   : natural := 0;
    constant UART_MODE_REG      : natural := 1;
    constant UART_STATUS_REG    : natural := 2;
    constant UART_TXD_REG       : natural := 3;
    constant UART_RXD_REG       : natural := 4;
    constant UART_SCRATCH_REG   : natural := 9;

    signal reg_addr             : unsigned(REG_ADDR_WIDTH-1 downto 0);
    signal reg_wdata            : std_logic_vector(31 downto 0);
    signal reg_wren             : std_logic;
    signal reg_be               : std_logic_vector(3 downto 0);
    signal reg_rdata            : std_logic_vector(31 downto 0);
    signal reg_req              : std_logic;
    signal reg_ack              : std_logic;
    signal reg_err              : std_logic;

    signal rd_regs              : reg_a(NUM_REGS-1 downto 0);
    signal wr_regs              : reg_a(NUM_REGS-1 downto 0);

    -- Defines expected parity to check on receive and sent on transmit
    --  00 - Even
    --  01 - Odd
    --  1x - None
    signal parity               : std_logic_vector(1 downto 0);
    -- Defines the number of bits to transmit or receive per character
    --  00 - 6 bits
    --  01 - 7 bits
    --  1x - 8 bits
    signal char                 : std_logic_vector(1 downto 0);
    -- Defines the number of expected stop bits
    --  00 - 1 stop bit
    --  01 - 1.5 stop bits
    --  1x - 2 stop bits
    signal nbstop               : std_logic_vector(1 downto 0);

begin

    -- UART control and status bits are sliced and diced here into the
    -- actual registers within the register block
    parity      <= wr_regs(UART_MODE_REG)(7 downto 6);
    char        <= wr_regs(UART_MODE_REG)(5 downto 4);
    nbstop      <= wr_regs(UART_MODE_REG)(3 downto 2);

    uart_core_i0: entity work.uart_core
    generic map (
        DEVICE              => DEVICE,
        CLK_FREQ            => CLK_FREQ,
        DEBUG               => DEBUG_UART_CORE
    )
    port map (
        clk                 => clk,
        rst                 => rst,
        -- rx_rst              => open,
        -- tx_rst              => open,
        -- rx_enable           => open,
        -- tx_enable           => open,
        parity              => parity,
        char                => char,
        nbstop              => nbstop,
        -- hw_flow_enable      => open,
        -- hw_flow_rts         => open,
        -- hw_flow_cts         => open,
        -- baud_div            => open,
        -- baud_cnt            => open,
        -- irq_enable          => open,
        -- irq_mask            => open,
        -- irq_clear           => open,
        -- irq_active          => open,
        -- rx_data             => open,
        -- tx_data             => open,
        rxd                 => rxd,
        txd                 => txd
    );

    axi4l_regs_i0: entity work.axi4l_regs
    generic map (
        BASE_OFFSET         => BASE_OFFSET,
        BASE_OFFSET_MASK    => BASE_OFFSET_MASK,
        REG_ADDR_WIDTH      => REG_ADDR_WIDTH
    )
    port map (
        clk                 => clk,
        rstn                => not rst,
        s_axi_awaddr        => axi4l_awaddr,
        s_axi_awvalid       => axi4l_awvalid,
        s_axi_awready       => axi4l_awready,
        s_axi_wdata         => axi4l_wdata,
        s_axi_wstrb         => axi4l_wstrb,
        s_axi_wvalid        => axi4l_wvalid,
        s_axi_wready        => axi4l_wready,
        s_axi_bresp         => axi4l_bresp,
        s_axi_bvalid        => axi4l_bvalid,
        s_axi_bready        => axi4l_bready,
        s_axi_araddr        => axi4l_araddr,
        s_axi_arvalid       => axi4l_arvalid,
        s_axi_arready       => axi4l_arready,
        s_axi_rdata         => axi4l_rdata,
        s_axi_rresp         => axi4l_rresp,
        s_axi_rvalid        => axi4l_rvalid,
        s_axi_rready        => axi4l_rready,
        reg_addr            => reg_addr,
        reg_wdata           => reg_wdata,
        reg_wren            => reg_wren,
        reg_be              => reg_be,
        reg_rdata           => reg_rdata,
        reg_req             => reg_req,
        reg_ack             => reg_ack,
        reg_err             => reg_err
    );

    uart_regs: entity work.reg_block
    generic map (
        REG_ADDR_WIDTH      => REG_ADDR_WIDTH,
        NUM_REGS            => NUM_REGS,
        REG_WRITE_MASK      => REG_WRITE_MASK
    )
    port map (
        clk                 => clk,
        rst                 => rst,
        reg_addr            => reg_addr,
        reg_wdata           => reg_wdata,
        reg_wren            => reg_wren,
        reg_be              => reg_be,
        reg_rdata           => reg_rdata,
        reg_req             => reg_req,
        reg_ack             => reg_ack,
        reg_err             => reg_err,
        rd_regs             => rd_regs,
        wr_regs             => wr_regs
    );

    uart_axi4l_ila: entity work.axi4l_ila
    port map (
        clk                 => clk,
        probe0(0)           => rst,
        probe1(0)           => axi4l_awvalid,
        probe2(0)           => axi4l_awready,
        probe3              => axi4l_awaddr,
        probe4(0)           => axi4l_wvalid,
        probe5(0)           => axi4l_wready,
        probe6              => axi4l_wdata,
        probe7              => axi4l_wstrb,
        probe8(0)           => axi4l_bvalid,
        probe9(0)           => axi4l_bready,
        probe10             => axi4l_bresp,
        probe11(0)          => axi4l_arvalid,
        probe12(0)          => axi4l_arready,
        probe13             => axi4l_araddr,
        probe14(0)          => axi4l_rvalid,
        probe15(0)          => axi4l_rready,
        probe16             => axi4l_rdata,
        probe17             => axi4l_rresp,
        probe18             => std_logic_vector(reg_addr),
        probe19             => reg_wdata,
        probe20(0)          => reg_wren,
        probe21             => reg_be,
        probe22             => reg_rdata,
        probe23(0)          => reg_req,
        probe24(0)          => reg_ack,
        probe25(0)          => reg_err
    );

end architecture structural;
