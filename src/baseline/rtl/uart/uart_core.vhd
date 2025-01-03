library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_core is
    generic (
        DEVICE              : string            := "7SERIES";
        RX_ENABLE           : boolean           := true;
        TX_ENABLE           : boolean           := true
    );
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;

        -- UART RX and TX control
        rx_rst              : in    std_logic;
        rx_en               : in    std_logic;
        tx_rst              : in    std_logic;
        tx_en               : in    std_logic;

        parity              : in    std_logic_vector(1 downto 0);
        char                : in    std_logic_vector(1 downto 0);
        nbstop              : in    std_logic_vector(1 downto 0);

        -- Hardware flow control
        -- hw_flow_enable      : in    std_logic;
        -- hw_flow_rts         : out   std_logic;
        -- hw_flow_cts         : in    std_logic; 

        -- Baud clock generator signals
        baud_div            : in    unsigned(14 downto 0);
        baud_cnt            : out   unsigned(14 downto 0);
        baud_gen_en         : in    std_logic;
    
        -- Interrupt signals
        -- irq_enable          : in    std_logic_vector(31 downto 0);
        -- irq_mask            : in    std_logic_vector(31 downto 0);
        -- irq_clear           : in    std_logic_vector(31 downto 0);
        -- irq_active          : out   std_logic_vector(31 downto 0);

        -- TX FIFO signals
    --        tx_fifo_full        : out   std_logic;

        -- RX and TX data ports are fixed at 8-bits, regardless of character size. For 6 or 7-bit
        -- characters, the unnecessary bits can be ignored or masked out
        -- rx_data             : out   std_logic_vector(7 downto 0);
        tx_data             : in    std_logic_vector(7 downto 0);
        tx_data_valid       : in    std_logic;
        tx_data_ready       : out   std_logic;

        -- Serial input ports (should map to a pad or an IBUF / OBUF)
        rxd                 : in    std_logic;
        txd                 : out   std_logic

    );

end entity uart_core;

architecture structural of uart_core is

    signal baud_tick        : std_logic;

begin

    -- Baud rate generator
    baud_rate_gen_i0: entity work.baud_rate_gen
    port map (
        clk             => clk,
        rst             => rst,
        baud_gen_en     => baud_gen_en,
        baud_div        => baud_div,
        baud_cnt        => baud_cnt,
        baud_tick       => baud_tick
    );

    -- Interrupt processing

    -- RX FIFO

    -- TX FIFO


    -- UART RX


end architecture structural;
