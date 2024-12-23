library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_core is
    generic (
        DEVICE              : string            := "7SERIES";
        CLK_FREQ            : integer           := 100000000;
        DEBUG               : boolean           := false
    );
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;

        -- Reset the entire RX or TX data path
        rx_rst              : in    std_logic;
        tx_rst              : in    std_logic;
        -- Enable or disable the RX or TX data path
        rx_enable           : in    std_logic;
        tx_enable           : in    std_logic;

        -- Defines expected parity to check on receive and sent on transmit
        --  00 - Even
        --  01 - Odd
        --  1x - None
        parity              : in    std_logic_vector(1 downto 0);
        -- Defines the number of bits to transmit or receive per character
        --  00 - 6 bits
        --  01 - 7 bits
        --  1x - 8 bits
        char                : in    std_logic_vector(1 downto 0);
        -- Hardware flow control
        hw_flow_enable      : in    std_logic;
        hw_flow_rts         : out   std_logic;
        hw_flow_cts         : in    std_logic; 

        -- Baud clock generator signals
        baud_div            : in    unsigned(11 downto 0);
        baud_cnt            : out   unsigned(11 downto 0);
    
        -- Interrupt signals
        irq_enable          : in    std_logic_vector(31 downto 0);
        irq_mask            : in    std_logic_vector(31 downto 0);
        irq_clear           : in    std_logic_vector(31 downto 0);
        irq_active          : out   std_logic_vector(31 downto 0);

        -- RX and TX data ports are fixed at 8-bits, regardless of character size. For 6 or 7-bit
        -- characters, the unnecessary bits can be ignored or masked out
        rx_data             : out   std_logic_vector(7 downto 0);
        tx_data             : in    std_logic_vector(7 downto 0);

        -- Serial input ports (should map to a pad or an IBUF / OBUF)
        rxd                 : in    std_logic;
        txd                 : out   std_logic

    );

end entity uart_core;

architecture structural of uart_core is

begin

    -- Interrupt processing

    -- Baud rate generator

    -- RX FIFO

    -- TX FIFO

    -- UART RX

    -- UART TX

end architecture structural;
