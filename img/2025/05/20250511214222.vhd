----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/22/2019 04:57:53 PM
-- Design Name: 
-- Module Name: pxl_div - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pxl_div is
    Port ( clk : in STD_LOGIC;
           div : in STD_LOGIC_VECTOR (4 downto 0);
           pxl_in : in STD_LOGIC_VECTOR (9 downto 0);
           pxl_out : out STD_LOGIC_VECTOR (9 downto 0);
           valid : in STD_LOGIC;
           ready : out STD_LOGIC);
end pxl_div;

architecture Behavioral of pxl_div is

component rng_trivium is

    generic (
        -- Number of output bits per clock cycle.
        -- Must be a power of two: either 1, 2, 4, 8, 16, 32 or 64.
        num_bits:   integer range 1 to 64;

        -- Default key.
        init_key:   std_logic_vector(79 downto 0);

        -- Default initialization vector.
        init_iv:    std_logic_vector(79 downto 0) );

    port (

        -- Clock, rising edge active.
        clk:        in  std_logic;

        -- Synchronous reset, active high.
        rst:        in  std_logic;

        -- High to request re-seeding of the generator.
        reseed:     in  std_logic;

        -- New key value (must be valid when reseed = '1').
        newkey:     in  std_logic_vector(79 downto 0);

        -- New initialization vector (must be valid when reseed = '1').
        newiv:      in  std_logic_vector(79 downto 0);

        -- High when the user accepts the current random data word
        -- and requests new random data for the next clock cycle.
        out_ready:  in  std_logic;

        -- High when valid random data is available on the output.
        -- This signal is low during the first (1152/num_bits) clock cycles
        -- after reset and after re-seeding, and high in all other cases.
        out_valid:  out std_logic;

        -- Random output data (valid when out_valid = '1').
        -- A new random word appears after every rising clock edge
        -- where out_ready = '1'.
        out_data:   out std_logic_vector(num_bits-1 downto 0) );

end component;

constant num_bits : integer := 4;
signal out_valid : std_logic;
signal out_data : std_logic_vector(num_bits-1 downto 0);

signal q1_valid : std_logic;
signal q2_valid : std_logic;
signal q3_valid : std_logic;
signal q4_valid : std_logic;
signal q5_valid : std_logic;

signal q1_div : unsigned(4 downto 0);
signal q2_div : unsigned(4 downto 0);
signal q3_div : unsigned(4 downto 0);

signal q_pxl_in : unsigned(9 downto 0);
signal q1_pxl_quot : unsigned(9 downto 0);
signal q2_pxl_quot : unsigned(9 downto 0);
signal q3_pxl_quot : unsigned(9 downto 0);
signal q_pxl_rem : unsigned(3 downto 0);
signal q_rand_range : unsigned(8 downto 0);
signal q_dither : unsigned(4 downto 0);
signal q_dither_div : unsigned(0 downto 0);
signal q_pxl_out : unsigned(9 downto 0);

begin

rng_trivium_inst: rng_trivium

    generic map(
        -- Number of output bits per clock cycle.
        -- Must be a power of two: either 1, 2, 4, 8, 16, 32 or 64.
        num_bits => num_bits, -- :  integer range 1 to 64;

        -- Default key.
        init_key => (others => '0'), -- :   std_logic_vector(79 downto 0);

        -- Default initialization vector.
        init_iv => (others => '0')) -- :    std_logic_vector(79 downto 0) );

    port map(

        -- Clock, rising edge active.
        clk => clk, -- : in  std_logic;

        -- Synchronous reset, active high.
        rst => '0', -- :        in  std_logic;

        -- High to request re-seeding of the generator.
        reseed => '0', -- :     in  std_logic;

        -- New key value (must be valid when reseed = '1').
        newkey => (others => '0'), -- :     in  std_logic_vector(79 downto 0);

        -- New initialization vector (must be valid when reseed = '1').
        newiv => (others => '0'), -- :      in  std_logic_vector(79 downto 0);

        -- High when the user accepts the current random data word
        -- and requests new random data for the next clock cycle.
        out_ready => '1', -- :  in  std_logic;

        -- High when valid random data is available on the output.
        -- This signal is low during the first (1152/num_bits) clock cycles
        -- after reset and after re-seeding, and high in all other cases.
        out_valid => out_valid, --:  out std_logic;

        -- Random output data (valid when out_valid = '1').
        -- A new random word appears after every rising clock edge
        -- where out_ready = '1'.
        out_data => out_data); -- :   out std_logic_vector(num_bits-1 downto 0) );


process(clk)
begin
if rising_edge(clk) then
	q1_valid <= valid;
	q2_valid <= q1_valid;
	q3_valid <= q2_valid;
	q4_valid <= q3_valid;
	q5_valid <= q4_valid;
	
end if;
end process;

process(clk)
begin
if rising_edge(clk) then
	if valid = '1' then
		q_pxl_in <= unsigned(pxl_in);
		q1_div <= unsigned(div);
	end if;
	
	if q1_valid = '1' then
	
		q2_div <= q1_div;
		
		case q1_div is
			when "00010" =>
				q1_pxl_quot <= '0' & q_pxl_in(9 downto 1);
				q_pxl_rem <= "000" & q_pxl_in(0 downto 0);
			when "00100" =>
				q1_pxl_quot <= "00" & q_pxl_in(9 downto 2);
				q_pxl_rem <= "00" & q_pxl_in(1 downto 0);
			when "01000" =>
				q1_pxl_quot <= "000" & q_pxl_in(9 downto 3);
				q_pxl_rem <= "0" & q_pxl_in(2 downto 0);
			when "10000" =>
				q1_pxl_quot <= "0000" & q_pxl_in(9 downto 4);
				q_pxl_rem <= q_pxl_in(3 downto 0);
			when others =>
				q1_pxl_quot <= q_pxl_in(9 downto 0);
				q_pxl_rem <= (others=>'0');
		end case;
		
		q_rand_range <= unsigned(out_data) * unsigned(q1_div);
		
	end if;
	
	if q2_valid = '1' then
	
		q2_pxl_quot <= q1_pxl_quot;
		q_dither <= q_rand_range(8 downto 4) + q_pxl_rem;
		q3_div <= q2_div;
		
	end if;
	
	if q3_valid = '1' then
	
		q3_pxl_quot <= q2_pxl_quot;
		
		case q3_div is
			when "00010" =>
				q_dither_div <= q_dither(1 downto 1);
			when "00100" =>
				q_dither_div <= q_dither(2 downto 2);
			when "01000" =>
				q_dither_div <= q_dither(3 downto 3);
			when "10000" =>
				q_dither_div <= q_dither(4 downto 4);
			when others =>
				q_dither_div <= "0";
		end case;
		
	end if;
	
	if q4_valid = '1' then
		q_pxl_out <= q3_pxl_quot + q_dither_div;
	end if;
	
end if;
end process;

pxl_out <= std_logic_vector(q_pxl_out);
ready <= q5_valid;

end Behavioral;
